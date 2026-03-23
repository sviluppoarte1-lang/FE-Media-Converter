#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#ifdef GDK_WINDOWING_WAYLAND
#include <gdk/gdkwayland.h>
#endif

#include "flutter/generated_plugin_registrant.h"
#include <glib.h>
#include <stdlib.h>
#include <string.h>
#include <flutter_linux/fl_method_channel.h>
#include <flutter_linux/fl_method_response.h>
#include <flutter_linux/fl_standard_method_codec.h>

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
  FlMethodChannel* method_channel;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  
  // Fix per Wayland: forza X11 se disponibile per evitare freeze
  const char* gdk_backend = g_getenv("GDK_BACKEND");
  if (gdk_backend == nullptr || strcmp(gdk_backend, "x11") != 0) {
    const char* wayland_display = g_getenv("WAYLAND_DISPLAY");
    const char* display = g_getenv("DISPLAY");
    
    // Se siamo su Wayland e X11 è disponibile, forza X11
    if (wayland_display != nullptr && display != nullptr) {
      g_setenv("GDK_BACKEND", "x11", TRUE);
      g_warning("Wayland detected. Forcing X11 backend for stability.");
    }
  }
  
  // Fix per NVIDIA drivers 580/590: applica variabili d'ambiente se non già impostate
  if (g_getenv("__GL_SYNC_TO_VBLANK") == nullptr) {
    g_setenv("__GL_SYNC_TO_VBLANK", "0", FALSE);
  }
  if (g_getenv("__GL_THREADED_OPTIMIZATIONS") == nullptr) {
    g_setenv("__GL_THREADED_OPTIMIZATIONS", "0", FALSE);
  }
  if (g_getenv("__GL_ALLOW_UNOFFICIAL_PROTOCOL") == nullptr) {
    g_setenv("__GL_ALLOW_UNOFFICIAL_PROTOCOL", "0", FALSE);
  }
  if (g_getenv("LIBGL_ALWAYS_INDIRECT") == nullptr) {
    g_setenv("LIBGL_ALWAYS_INDIRECT", "1", FALSE);
  }
  if (g_getenv("MESA_GL_VERSION_OVERRIDE") == nullptr) {
    g_setenv("MESA_GL_VERSION_OVERRIDE", "3.3", FALSE);
  }
  
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used by
  // GNOME applications. See:
  // https://developer.gnome.org/hig/stable/header-bars.html.en
  GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
  gtk_widget_show(GTK_WIDGET(header_bar));
  gtk_header_bar_set_title(header_bar, "FE Media Converter");
  gtk_header_bar_set_show_close_button(header_bar, TRUE);
  gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));

  gtk_window_set_default_size(window, 1280, 720);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  // Register method channel for command line arguments
  // IMPORTANTE: Registra il channel PRIMA di mostrare la view per assicurarsi che sia disponibile
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  self->method_channel = fl_method_channel_new(
      fl_plugin_registry_get_messenger(FL_PLUGIN_REGISTRY(view)),
      "com.videoconverterpro/args",
      FL_METHOD_CODEC(codec));
  
  fl_method_channel_set_method_call_handler(
      self->method_channel,
      [](FlMethodChannel* channel, const gchar* method, FlValue* args,
         gpointer user_data) -> FlMethodResponse* {
        MyApplication* self = MY_APPLICATION(user_data);
        
        if (g_strcmp0(method, "getCommandLineArguments") == 0) {
          g_autoptr(FlValue) result = fl_value_new_list();
          if (self->dart_entrypoint_arguments != nullptr) {
            g_warning("Passing %d command line arguments to Flutter", 
                     g_strv_length(self->dart_entrypoint_arguments));
            for (int i = 0; self->dart_entrypoint_arguments[i] != nullptr; i++) {
              g_warning("Argument %d: %s", i, self->dart_entrypoint_arguments[i]);
              fl_value_append_take(result, fl_value_new_string(self->dart_entrypoint_arguments[i]));
            }
          } else {
            g_warning("No command line arguments available");
          }
          return fl_method_success_response_new(result);
        }
        
        return fl_method_not_implemented_response_new();
      },
      self, nullptr);
  
  g_warning("Method channel 'com.videoconverterpro/args' registered");

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  g_clear_object(&self->method_channel);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}