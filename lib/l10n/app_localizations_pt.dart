// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'FE Media Converter 🎬🎵🖼️';

  @override
  String get conversion => 'Conversão';

  @override
  String get queue => 'Fila';

  @override
  String get settings => 'Configurações';

  @override
  String get about => 'Sobre';

  @override
  String get close => 'Fechar';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get remove => 'Remover';

  @override
  String get pause => 'Pausar';

  @override
  String get resume => 'Retomar';

  @override
  String get stop => 'Parar';

  @override
  String get clear => 'Limpar';

  @override
  String get clearAll => 'Limpar tudo';

  @override
  String get removeCompletedFiles => 'Remove completed files from queue?';

  @override
  String get waitingForConversion => 'Waiting for conversion';

  @override
  String get emptyEntireQueue => 'Empty entire queue?';

  @override
  String get conversionCompleted => 'Conversion completed';

  @override
  String get conversionFailed => 'Conversion failed';

  @override
  String get conversionPausedStatus => 'Conversion paused';

  @override
  String get removeFromQueueQuestion => 'Remove from queue?';

  @override
  String areYouSureRemove(Object fileName) {
    return 'Are you sure you want to remove $fileName?';
  }

  @override
  String areYouSureStop(Object fileName) {
    return 'Are you sure you want to stop $fileName?';
  }

  @override
  String get pauseConversionQuestion => 'Pause conversion?';

  @override
  String areYouSurePause(Object fileName) {
    return 'Are you sure you want to pause $fileName?';
  }

  @override
  String get stopConversionQuestion => 'Stop conversion?';

  @override
  String get browse => 'Procurar';

  @override
  String get addToQueue => 'Adicionar à fila';

  @override
  String get clearSelection => 'Limpar seleção';

  @override
  String get videoCodec => 'Codec de vídeo';

  @override
  String get videoBitrate => 'Taxa de bits de vídeo';

  @override
  String get qualityMode => 'Modo de qualidade';

  @override
  String get constantQuality => 'Qualidade constante';

  @override
  String get constantBitrate => 'Taxa de bits constante';

  @override
  String get crfDescription => 'Mantém qualidade constante, tamanho de arquivo variável';

  @override
  String get bitrateDescription => 'Mantém tamanho de arquivo constante, qualidade variável';

  @override
  String get videoSettings => 'Configurações de vídeo';

  @override
  String get advancedVideoSettings => 'Configurações avançadas de vídeo';

  @override
  String get codecDescription => 'Selecionar formato de compressão de vídeo';

  @override
  String get bitrateMode => 'Modo de taxa de bits';

  @override
  String get mediaType => 'Tipo de mídia';

  @override
  String selectMedia(Object mediaType) {
    return 'Selecionar $mediaType';
  }

  @override
  String get noFilesSelected => 'Nenhum arquivo selecionado';

  @override
  String clickToBrowse(Object mediaType) {
    return 'Clique em \"Procurar $mediaType\" para selecionar arquivos';
  }

  @override
  String filesSelected(Object count) {
    return '$count arquivos selecionados';
  }

  @override
  String get selectionCleared => 'Seleção limpa';

  @override
  String filesAddedToQueue(Object count) {
    return '$count arquivos adicionados à fila';
  }

  @override
  String get dropFilesHere => 'Arraste arquivos aqui para adicioná-los';

  @override
  String get dragAndDropSupported => 'Arraste e solte arquivos aqui';

  @override
  String outputFormat(Object mediaType) {
    return 'Formato de saída - $mediaType';
  }

  @override
  String get qualitySettings => 'Configurações de qualidade';

  @override
  String get videoQuality => 'Qualidade de vídeo:';

  @override
  String get audioQuality => 'Qualidade de áudio:';

  @override
  String get videoFilters => 'Filtros avançados de vídeo';

  @override
  String get audioFilters => 'Filtros profissionais de áudio';

  @override
  String get conversionQueue => 'Fila de conversão';

  @override
  String completedCount(Object completed, Object total) {
    return '$completed/$total concluídos';
  }

  @override
  String get converting => 'Convertendo...';

  @override
  String get noFilesInQueue => 'Nenhum arquivo na fila';

  @override
  String get addFilesFromConversion => 'Adicione arquivos da página de Conversão\npara começar a converter';

  @override
  String get removeFromQueue => 'Remover da fila';

  @override
  String get pauseConversion => 'Pausar conversão';

  @override
  String get stopConversion => 'Parar conversão';

  @override
  String fileRemoved(Object fileName) {
    return '\"$fileName\" removido da fila';
  }

  @override
  String filePaused(Object fileName) {
    return '\"$fileName\" pausado';
  }

  @override
  String fileStopped(Object fileName) {
    return '\"$fileName\" parado';
  }

  @override
  String get pending => 'Pendente';

  @override
  String get processing => 'Processando';

  @override
  String get paused => 'Pausado';

  @override
  String get completed => 'Concluído';

  @override
  String get failed => 'Falhou';

  @override
  String get calculating => 'Calculando...';

  @override
  String get waiting => 'Aguardando';

  @override
  String get conversionInProgress => 'Conversão em andamento';

  @override
  String pausedAt(Object time) {
    return 'Pausado às $time';
  }

  @override
  String completedAt(Object time) {
    return 'Concluído $time';
  }

  @override
  String failedAt(Object time) {
    return 'Falhou $time';
  }

  @override
  String pausedAtTime(Object time) {
    return 'Paused at $time';
  }

  @override
  String completedAtTime(Object time) {
    return 'Completed at $time';
  }

  @override
  String failedAtTime(Object time) {
    return 'Failed at $time';
  }

  @override
  String get theme => 'Tema';

  @override
  String get system => 'Sistema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Escuro';

  @override
  String get language => 'Idioma';

  @override
  String get outputFolder => 'Pasta de saída';

  @override
  String get sameAsInput => 'Igual à pasta de entrada';

  @override
  String get cpuThreads => 'Threads de CPU';

  @override
  String get autoDetect => 'Detecção automática';

  @override
  String get concurrentConversions => 'Conversões simultâneas';

  @override
  String get concurrentConversionsDesc => 'Número de arquivos para converter simultaneamente';

  @override
  String get gpuAcceleration => 'Aceleração GPU';

  @override
  String get useGpu => 'Usar GPU para conversão';

  @override
  String get gpuCompatibility => 'Melhor desempenho mas compatibilidade limitada';

  @override
  String get requiresCompatibleHardware => 'Requer hardware e drivers compatíveis';

  @override
  String get gpuType => 'Tipo de GPU';

  @override
  String get autoDetection => 'Detecção automática';

  @override
  String get selectGpuType => 'Selecionar o tipo de placa gráfica instalada';

  @override
  String get information => 'Informações';

  @override
  String get version => 'Versão';

  @override
  String get professionalMediaConversion => 'Aplicativo profissional de conversão de mídia';

  @override
  String get usesFfmpeg => 'Usa FFmpeg para conversões. Certifique-se de que o FFmpeg está instalado no seu sistema.';

  @override
  String get extractAudioOnly => 'Extrair apenas áudio';

  @override
  String get extractAudioFromVideo => 'Extrair áudio de arquivos de vídeo (ex. MP4 para MP3, MOV para WAV)';

  @override
  String get video => 'Vídeo';

  @override
  String get audio => 'Áudio';

  @override
  String get image => 'Imagem';

  @override
  String get videos => 'Vídeos';

  @override
  String get audios => 'Áudios';

  @override
  String get images => 'Imagens';

  @override
  String get formats => 'formatos';

  @override
  String get filtersActive => 'Filtros ativos';

  @override
  String get resetAll => 'Redefinir tudo';

  @override
  String get noiseReduction => 'Redução de ruído';

  @override
  String get noiseReductionStrength => 'Intensidade de redução de ruído';

  @override
  String get reducesDigitalNoise => 'Reduz ruído digital e granulação. Valores altos podem suavizar a imagem.';

  @override
  String get qualityEnhancement => 'Melhoria de qualidade';

  @override
  String get sharpness => 'Nitidez';

  @override
  String get brightness => 'Brilho';

  @override
  String get contrast => 'Contraste';

  @override
  String get saturation => 'Saturação';

  @override
  String get gamma => 'Gama';

  @override
  String get advancedCorrections => 'Correções avançadas';

  @override
  String get videoStabilization => 'Estabilização de vídeo';

  @override
  String get reducesCameraShake => 'Reduz tremores da câmera';

  @override
  String get deinterlacing => 'Desentrelaçamento';

  @override
  String get removesInterlacedLines => 'Remove linhas de vídeos entrelaçados';

  @override
  String get colorProfiles => 'Perfis de cor';

  @override
  String get none => 'Nenhum';

  @override
  String get vivid => 'Vívido';

  @override
  String get cinematic => 'Cinematográfico';

  @override
  String get blackWhite => 'Preto e branco';

  @override
  String get sepia => 'Sépia';

  @override
  String get activeEffectsPreview => 'Pré-visualização de efeitos ativos:';

  @override
  String get noActiveFilters => 'Nenhum filtro ativo';

  @override
  String get volumeDynamics => 'Volume e dinâmica';

  @override
  String get volume => 'Volume';

  @override
  String get compression => 'Compressão';

  @override
  String get normalization => 'Normalização';

  @override
  String get levelsVolumeAutomatically => 'Nivela o volume automaticamente';

  @override
  String get equalizer => 'Equalizador';

  @override
  String get bass => 'Graves';

  @override
  String get treble => 'Agudos';

  @override
  String get equalizerPreset => 'Predefinição de equalizador:';

  @override
  String get bassBoost => 'Reforço de graves';

  @override
  String get trebleBoost => 'Reforço de agudos';

  @override
  String get voice => 'Voz';

  @override
  String get audioCleaning => 'Limpeza de áudio';

  @override
  String get removeNoise => 'Remover ruído';

  @override
  String get reducesBackgroundHiss => 'Reduz chiado de fundo';

  @override
  String get noiseThreshold => 'Limiar de ruído';

  @override
  String get reverb => 'Reverberação';

  @override
  String get activeAudioEffects => 'Efeitos de áudio ativos:';

  @override
  String get noActiveAudioFilters => 'Nenhum filtro de áudio ativo';

  @override
  String excellentQuality(Object crf) {
    return 'Excelente (CRF: $crf)';
  }

  @override
  String greatQuality(Object crf) {
    return 'Muito bom (CRF: $crf)';
  }

  @override
  String goodQuality(Object crf) {
    return 'Bom (CRF: $crf)';
  }

  @override
  String averageQuality(Object crf) {
    return 'Médio (CRF: $crf)';
  }

  @override
  String lowQualityLabel(Object crf) {
    return 'Baixo (CRF: $crf)';
  }

  @override
  String get crfScale => 'CRF: 0 (Melhor) - 51 (Pior)';

  @override
  String get bitrateScale => 'Taxa de bits: 64 kbps - 320 kbps';

  @override
  String get audioCodec => 'Codec de áudio';

  @override
  String get audioCodecDesc => 'Selecionar codec de áudio para o arquivo de saída';

  @override
  String get aacDescription => 'AAC - High compatibility, good quality';

  @override
  String get mp3Description => 'MP3 - Maximum compatibility';

  @override
  String get flacDescription => 'FLAC - Lossless, maximum quality';

  @override
  String get opusDescription => 'Opus - Excellent efficiency';

  @override
  String get vorbisDescription => 'Vorbis - Open source, good quality';

  @override
  String get pcmDescription => 'PCM - Uncompressed audio';

  @override
  String audioCodecDefaultDescription(Object codec) {
    return 'Selected audio codec: $codec';
  }

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(Object minutes) {
    return '$minutes min ago';
  }

  @override
  String hoursAgo(Object hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(Object days) {
    return '$days days ago';
  }

  @override
  String get error => 'Erro';

  @override
  String get files => 'arquivos';

  @override
  String get customResolution => 'Resolução personalizada';

  @override
  String get customWidth => 'Largura (px)';

  @override
  String get customHeight => 'Altura (px)';

  @override
  String get originalResolution => 'Resolução da imagem';

  @override
  String get previewOriginal => 'Pré-visualização original';

  @override
  String get previewModified => 'Pré-visualização modificada';

  @override
  String get useCustomResolution => 'Usar resolução personalizada';

  @override
  String get customResolutionDesc => 'Definir largura e altura específicas (ex. 1920x1080)';

  @override
  String get loadingResolution => 'Carregando resolução...';

  @override
  String get resolutionNotAvailable => 'Resolução não disponível';

  @override
  String get selectImageForResolution => 'Selecionar uma imagem para ver a resolução';

  @override
  String get resolutionDescription => 'Definir uma resolução específica. Se definir apenas largura ou altura, a proporção é mantida.';

  @override
  String get previewDescription => 'Ver a imagem original ou com filtros aplicados';

  @override
  String get advancedUpscalingAlgorithms => 'Double or quadruple the image resolution. Uses advanced upscaling algorithms.';

  @override
  String audioCodecSection(Object mediaType) {
    return 'Audio Codec - $mediaType';
  }

  @override
  String get ffmpegVersionCheck => 'Verificação de versão do FFmpeg';

  @override
  String get ffmpegNotInstalled => 'FFmpeg não está instalado ou a versão está desatualizada';

  @override
  String get ffmpegVersionRequired => 'Versão necessária: 8.0.1';

  @override
  String ffmpegCurrentVersion(Object version) {
    return 'Versão atual: $version';
  }

  @override
  String get ffmpegNeedsUpdate => 'FFmpeg precisa ser atualizado para a versão 8.0.1';

  @override
  String get installFFmpeg => 'Instalar FFmpeg 8.0.1';

  @override
  String get installFFmpegDesc => 'Isso instalará o FFmpeg 8.0.1 usando privilégios de administrador. A senha será armazenada com segurança para uso futuro.';

  @override
  String get enterSudoPassword => 'Inserir senha de administrador';

  @override
  String get passwordRequired => 'A senha é necessária';

  @override
  String get installingFFmpeg => 'Instalando FFmpeg...';

  @override
  String get ffmpegInstallSuccess => 'FFmpeg 8.0.1 instalado com sucesso!';

  @override
  String ffmpegInstallFailed(Object error) {
    return 'Instalação do FFmpeg falhou: $error';
  }

  @override
  String detectedDistribution(Object distro) {
    return 'Distribuição detectada: $distro';
  }

  @override
  String get addingRepository => 'Adicionando repositório...';

  @override
  String get updatingPackages => 'Atualizando lista de pacotes...';

  @override
  String get installingPackage => 'Instalando FFmpeg...';

  @override
  String get passwordStored => 'Senha armazenada com segurança para instalações futuras';

  @override
  String get skipInstallation => 'Pular instalação';

  @override
  String get manualInstall => 'Instalação manual';

  @override
  String get manualInstallDesc => 'Você pode instalar o FFmpeg manualmente usando os comandos abaixo';

  @override
  String get howToInstallFfmpeg => 'How to install FFmpeg';

  @override
  String get onFedora => 'On Fedora';

  @override
  String get onUbuntuDebian => 'On Ubuntu/Debian';

  @override
  String get onWindows => 'On Windows';

  @override
  String get onMacOS => 'On macOS';

  @override
  String get openTerminalAndRun => 'Open terminal and run';

  @override
  String get downloadFromFfmpeg => 'Download from FFmpeg website';

  @override
  String get useHomebrew => 'Use Homebrew';

  @override
  String get afterInstallingRestart => 'After installing, restart the application';

  @override
  String get clickToOpenGuide => 'Click to open installation guide';

  @override
  String get audioPreview => 'Pré-visualização de áudio';

  @override
  String get audioPreviewDescription => 'Ouvir o áudio original ou com filtros aplicados';

  @override
  String get openWithSystemPlayer => 'Abrir com player do sistema';

  @override
  String get audioFileReady => 'Arquivo de áudio pronto para reprodução';

  @override
  String get modifiedAudioGenerated => 'Áudio modificado gerado (primeiros 10 segundos)';

  @override
  String get fileWillOpenWithDefaultPlayer => 'O arquivo será aberto com o player de áudio padrão do sistema';

  @override
  String get videoQualityMode => 'Modo de qualidade de vídeo';

  @override
  String get constantQualityLabel => 'CRF (Qualidade constante)';

  @override
  String get constantBitrateLabel => 'Taxa de bits (Tamanho de arquivo)';

  @override
  String get videoBitrateLabel => 'Taxa de bits de vídeo';

  @override
  String get crfQualityRange => 'CRF: 0 (Melhor qualidade) - 51 (Pior qualidade)';

  @override
  String get bitrateQualityRange => 'Taxa de bits: 500 kbps (Baixa qualidade) - 20,000 kbps (Muito alta qualidade)';

  @override
  String get qualityLabel => 'Qualidade:';

  @override
  String get videoCodecDescriptionLibx264 => 'Excellent compatibility, good compression';

  @override
  String get videoCodecDescriptionLibx265 => 'Better compression, limited compatibility';

  @override
  String get videoCodecDescriptionLibvpx => 'Open source codec for Web';

  @override
  String get videoCodecDescriptionLibvpxVp9 => 'Modern codec for high quality';

  @override
  String get videoCodecDescriptionMpeg4 => 'Universal compatibility';

  @override
  String get videoCodecDescriptionLibaomAv1 => 'Next-gen codec, advanced compression';

  @override
  String get videoCodecDescriptionDefault => 'Video codec';

  @override
  String get audioQualityHighest => 'Qualidade mais alta (Sem perdas)';

  @override
  String get audioQualityHigh => 'Alta qualidade (Transparência)';

  @override
  String get audioQualityMedium => 'Qualidade média (Bom equilíbrio)';

  @override
  String get audioQualityLow => 'Baixa qualidade (Compatibilidade)';

  @override
  String get selectVideoForAnalysis => 'Selecionar um vídeo para análise automática';

  @override
  String get analyzeVideoQuality => 'Analisar qualidade de vídeo';

  @override
  String get analyzingVideoQuality => 'Analisando qualidade de vídeo...';

  @override
  String get videoAnalyzedNoIssues => 'Vídeo analisado - Sem problemas críticos';

  @override
  String problemsDetectedRecommendations(Object problems, Object recommendations) {
    return '$problems problemas detectados - $recommendations recomendações';
  }

  @override
  String get intelligentVideoAnalysis => 'Análise inteligente de vídeo';

  @override
  String get automaticOptimizations => 'Otimizações automáticas';

  @override
  String get autoOptimization => 'Otimização automática';

  @override
  String get autoOptimizationDesc => 'Aplicar melhores configurações baseadas em análise';

  @override
  String get lowQuality => 'Baixa qualidade ⭐';

  @override
  String get lowQualityDesc => 'OTIMIZAÇÃO MÁXIMA para vídeos de baixa qualidade com muito ruído';

  @override
  String get ultraQuality => 'Qualidade ultra';

  @override
  String get ultraQualityDesc => 'Aprimoramento profissional com todos os filtros avançados';

  @override
  String get lowLight => 'Pouca iluminação';

  @override
  String get lowLightDesc => 'Melhora vídeos em condições de pouca luz';

  @override
  String get detailRecovery => 'Recuperação de detalhes';

  @override
  String get detailRecoveryDesc => 'Recupera detalhes e texturas perdidos';

  @override
  String get compressionFix => 'Correção de compressão';

  @override
  String get compressionFixDesc => 'Remove artefatos de compressão pesada';

  @override
  String get filmRestoration => 'Restauração de filme';

  @override
  String get filmRestorationDesc => 'Otimizado para vídeos antigos e filmes';

  @override
  String get fundamentalFilters => 'Filtros fundamentais';

  @override
  String get qualityAndDetails => 'Qualidade e detalhes';

  @override
  String get noiseReductionLabel => 'Redução de ruído';

  @override
  String get colorAndLight => 'Cor e luz';

  @override
  String get redBalance => 'Balanço vermelho';

  @override
  String get greenBalance => 'Balanço verde';

  @override
  String get blueBalance => 'Balanço azul';

  @override
  String get deinterlacingLabel => 'Desentrelaçamento';

  @override
  String get deinterlacingDesc => 'Remove linhas entrelaçadas de vídeos mais antigos';

  @override
  String get stabilizationLabel => 'Estabilização';

  @override
  String get stabilizationDesc => 'Reduz tremores da câmera';

  @override
  String get detailEnhancement => 'Aprimoramento de detalhes';

  @override
  String get detailEnhancementDesc => 'Melhora a definição de detalhes';

  @override
  String get gpuAccelerationLabel => 'Aceleração GPU';

  @override
  String get useGpuForConversion => 'Usar GPU para conversão';

  @override
  String get useGpuForConversionDesc => 'Move codificação de vídeo para placa gráfica (se disponível)';

  @override
  String get gpuPreset => 'Predefinição GPU (velocidade vs qualidade)';

  @override
  String get gpuPresetFast => 'Rápido';

  @override
  String get gpuPresetFastDesc => 'Velocidade máxima, qualidade ligeiramente inferior';

  @override
  String get gpuPresetMedium => 'Médio';

  @override
  String get gpuPresetMediumDesc => 'Equilibrado entre velocidade e qualidade (recomendado)';

  @override
  String get gpuPresetHighQuality => 'Alta qualidade';

  @override
  String get gpuPresetHighQualityDesc => 'Melhor qualidade possível, conversão mais lenta';

  @override
  String get drunetDenoisingTitle => 'DRUNet (AI denoising)';

  @override
  String get drunetDenoisingDesc => 'Deep learning denoising when drunet_model.pth is in models/drunet/. On by default.';

  @override
  String get sceneDetectionTitle => 'Scene detection (PySceneDetect)';

  @override
  String get sceneDetectionDesc => 'Scene analysis for smarter encoding hints. On by default.';

  @override
  String get useSceneOptimizationTitle => 'Scene-based optimization';

  @override
  String get useSceneOptimizationDesc => 'Apply bitrate/quality recommendations from scene analysis.';

  @override
  String get noneLabel => 'Nenhum';

  @override
  String get vividLabel => 'Vívido';

  @override
  String get cinematicLabel => 'Cinematográfico';

  @override
  String get blackWhiteLabel => 'Preto e branco';

  @override
  String get sepiaLabel => 'Sépia';

  @override
  String get imageFiltersTitle => 'Filtros de imagem';

  @override
  String get qualityEnhancementLabel => 'Aprimoramento de qualidade';

  @override
  String get imageUpscaling => 'Upscaling de imagem';

  @override
  String get enableImageUpscaling => 'Habilitar upscaling';

  @override
  String get enableImageUpscalingDesc => 'Aumenta a resolução da imagem';

  @override
  String get upscalingFactor => 'Fator de upscaling';

  @override
  String get upscalingDisabledWithCustom => 'O upscaling está desabilitado ao usar resolução personalizada.';

  @override
  String get imageColorProfiles => 'Perfis de cor';

  @override
  String get userGuideMenu => 'Guia';

  @override
  String get userGuideTitle => 'Guia de utilização';

  @override
  String get userGuideIntro => 'Resumo do FE Media Converter: escolha o tipo de média, adicione ficheiros, formato e qualidade, ajuste filtros se precisar e use a fila para converter. As definições mantêm-se entre sessões.';

  @override
  String get guideSectionQuickStartTitle => 'Início rápido';

  @override
  String get guideSectionQuickStartBody => '1) Escolha Vídeo, Áudio ou Imagem à esquerda.\n2) Procure ou arraste ficheiros para a janela.\n3) Escolha formato de saída e codecs.\n4) Ajuste a qualidade (CRF ou bitrate).\n5) Adicione à fila, abra o separador Fila e inicie.\n6) Definições: pasta de saída, tema, idioma, threads CPU e GPU.';

  @override
  String get guideSectionFormatsTitle => 'Formatos e codecs';

  @override
  String get guideSectionFormatsBody => 'Cada modo tem os seus presets. Vídeo: H.264, HEVC, VP9, AV1, etc. Áudio: AAC, MP3, Opus, FLAC… Imagens: PNG, JPEG, WebP… Pode extrair só áudio do vídeo se a opção estiver ativa nas definições.';

  @override
  String get guideSectionVideoTitle => 'Vídeo: filtros e IA';

  @override
  String get guideSectionVideoBody => 'Filtros avançados: redução de ruído, nitidez, cor (brilho, contraste, saturação, gamma, RGB), estabilização, desentrelaçamento, perfis criativos. A análise inteligente pode sugerir otimizações (pouca luz, compressão forte, aspeto de filme antigo).\nDRUNet opcional descarrega um modelo neural. Deteção de cenas (PySceneDetect) analisa cortes; ative a otimização por cenas para aplicar as sugestões.\nAceleração GPU move a codificação para a placa; escolha um equilíbrio velocidade/qualidade.';

  @override
  String get guideSectionAudioTitle => 'Filtros de áudio';

  @override
  String get guideSectionAudioBody => 'Volume, compressão e normalização. Equalizador graves/agudos e presets (ex.: reforço de graves, voz). Limpeza reduz ruído de fundo; reverberação acrescenta espaço. A pré-visualização compara o original com o processado quando disponível.';

  @override
  String get guideSectionImageTitle => 'Imagens: resolução e upscaling';

  @override
  String get guideSectionImageBody => 'Ajustes de qualidade/cor semelhantes ao vídeo. Largura/altura personalizadas ou manter proporção. Super-resolução aumenta a definição; desativa-se se entrar em conflito com resolução fixa. Perfis de cor para estilos rápidos.';

  @override
  String get guideSectionQueueTitle => 'Fila e paralelismo';

  @override
  String get guideSectionQueueBody => 'A fila mostra tarefas pendentes, ativas, em pausa, concluídas ou falhadas. Pode pausar, retomar, parar ou remover. Conversões simultâneas nas definições controlam a carga no CPU.';

  @override
  String get guideSectionSettingsTitle => 'Definições';

  @override
  String get guideSectionSettingsBody => 'Pasta de saída vazia = junto a cada ficheiro de origem. Threads CPU limitam o FFmpeg (0 = automático). Tema e idioma após confirmação. Formatos e codecs predefinidos são guardados por tipo de média.';

  @override
  String get guideSectionModelsTitle => 'Modelos e Python';

  @override
  String get guideSectionModelsBody => 'DRUNet e os scripts de cenas usam o ambiente Python da app. Na primeira execução pode pedir-se a descarga dos pesos DRUNet (~125 MB). Pode alterar a pasta de modelos; existe cache por omissão na pasta pessoal.';

  @override
  String get guideSectionDepsTitle => 'FFmpeg e verificação';

  @override
  String get guideSectionDepsBody => 'O FFmpeg deve estar instalado e razoavelmente atualizado. Se aparecer o ecrã de dependências, siga a instalação guiada ou manual e tente de novo. Python 3 e pip/venv melhoram as funções opcionais.';

  @override
  String get pythonSetupTitle => 'Componentes Python opcionais';

  @override
  String get pythonSetupIntro => 'O DRUNet e a deteção de cenas usam um ambiente virtual Python local (PyTorch, etc.). A transferência pode ser grande e faz-se na primeira execução da app, não durante a instalação do pacote.\n\nInstale agora ou ignore e use o resto sem estas funções.';

  @override
  String get pythonSetupInstall => 'Transferir e instalar';

  @override
  String get pythonSetupSkip => 'Ignorar por agora';

  @override
  String get pythonSetupRunning => 'A instalar pacotes (pode demorar vários minutos)…';

  @override
  String get pythonSetupPleaseWait => 'Aguarde…';

  @override
  String get pythonSetupSuccess => 'Ambiente Python pronto. DRUNet e ferramentas de cenas disponíveis.';

  @override
  String pythonSetupFailed(int code) {
    return 'Falhou (código: $code). Tente novamente ou execute scripts/python/setup_python_env.sh manualmente.';
  }

  @override
  String get pythonSetupRetry => 'Tentar de novo';
}
