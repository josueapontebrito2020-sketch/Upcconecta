// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'UpcConecta';

  @override
  String get logoLabel => 'Logo de UPC Conecta';

  @override
  String get backTooltip => 'Volver';

  @override
  String get retry => 'Reintentar';

  @override
  String get loginTitle => 'Inicia sesión';

  @override
  String get loginSubtitle => 'Usa tu correo institucional de la UPC.';

  @override
  String get emailLabel => 'Correo institucional';

  @override
  String get emailHint => 'nombre@unicesar.edu.co';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get forgotPasswordLink => '¿Olvidaste tu contraseña?';

  @override
  String get signInButton => 'Iniciar sesión';

  @override
  String get noAccountQuestion => '¿Aún no tienes cuenta?';

  @override
  String get createAccountLink => 'Crear cuenta';

  @override
  String get registerTitle => 'Crea tu cuenta';

  @override
  String registerSubtitle(String domain) {
    return 'Solo para estudiantes y profesores con correo @$domain.';
  }

  @override
  String get photoAdd => 'Agregar foto de perfil';

  @override
  String get photoChange => 'Cambiar foto';

  @override
  String get photoRemove => 'Quitar foto';

  @override
  String get photoFromGallery => 'Elegir de la galería';

  @override
  String get photoFromCamera => 'Tomar una foto';

  @override
  String get photoOptional => 'Opcional';

  @override
  String get photoTooLarge => 'La foto pesa más de 2 MB. Elige otra.';

  @override
  String get photoInvalidType => 'Usa una foto JPG, PNG o WEBP.';

  @override
  String get fullNameLabel => 'Nombre completo';

  @override
  String get usernameLabel => 'Nombre de usuario';

  @override
  String get usernameHelper =>
      'Así te encontrarán. Solo minúsculas, números, punto o guion bajo.';

  @override
  String get birthDateLabel => 'Fecha de nacimiento';

  @override
  String get birthDateHint => 'dd/mm/aaaa';

  @override
  String get birthDateCalendarTooltip => 'Abrir calendario';

  @override
  String get facultyLabel => 'Facultad';

  @override
  String get programLabel => 'Carrera';

  @override
  String get programHintNoFaculty => 'Primero elige tu facultad';

  @override
  String get academicLoadError => 'No se pudo cargar la lista.';

  @override
  String get phoneLabel => 'Celular (opcional)';

  @override
  String get phoneHint => '3001234567';

  @override
  String get bioLabel => 'Descripción (opcional)';

  @override
  String get bioHint =>
      'Cuéntale a la comunidad qué sabes hacer o qué ofreces.';

  @override
  String newPasswordHelper(int minLength) {
    return 'Mínimo $minLength caracteres, con letras y números.';
  }

  @override
  String get confirmPasswordLabel => 'Confirmar contraseña';

  @override
  String get dataConsent =>
      'Autorizo el tratamiento de mis datos personales según la Ley 1581 de 2012.';

  @override
  String get createAccountButton => 'Crear cuenta';

  @override
  String get haveAccountQuestion => '¿Ya tienes cuenta?';

  @override
  String get verifyTitle => 'Verifica tu correo';

  @override
  String verifySubtitle(String email) {
    return 'Enviamos un código a $email. Escríbelo aquí para activar tu cuenta.';
  }

  @override
  String get verifyNoPending =>
      'No hay un registro en curso. Crea tu cuenta para recibir un código.';

  @override
  String get codeLabel => 'Código de verificación';

  @override
  String get checkSpam =>
      '¿No te llegó? Revisa la carpeta de spam o pide otro código.';

  @override
  String get verifyButton => 'Verificar';

  @override
  String get resendCodeButton => 'Reenviar código';

  @override
  String get codeResent => 'Te enviamos un código nuevo.';

  @override
  String get forgotTitle => 'Recupera tu contraseña';

  @override
  String get forgotSubtitle =>
      'Escribe tu correo institucional y te enviaremos un código para crear una contraseña nueva.';

  @override
  String get sendCodeButton => 'Enviar código';

  @override
  String get resetTitle => 'Crea una contraseña nueva';

  @override
  String resetSubtitle(String email) {
    return 'Escribe el código que enviamos a $email y tu contraseña nueva.';
  }

  @override
  String get resetNoPending =>
      'Primero pide un código con tu correo institucional.';

  @override
  String get newPasswordLabel => 'Contraseña nueva';

  @override
  String get resetButton => 'Cambiar contraseña';

  @override
  String get validationEmailRequired => 'Escribe tu correo institucional.';

  @override
  String validationEmailIncomplete(String domain) {
    return 'Escribe el correo completo, por ejemplo nombre@$domain.';
  }

  @override
  String validationEmailNotInstitutional(String domain) {
    return 'Usa tu correo institucional @$domain.';
  }

  @override
  String get validationPasswordRequired => 'Escribe tu contraseña.';

  @override
  String get validationFullNameRequired => 'Escribe tu nombre completo.';

  @override
  String get validationFullNameIncomplete => 'Escribe tu nombre y apellido.';

  @override
  String get validationUsernameRequired => 'Elige un nombre de usuario.';

  @override
  String validationUsernameFormat(int min, int max) {
    return 'Usa de $min a $max caracteres: minúsculas, números, punto o guion bajo.';
  }

  @override
  String get validationBirthDateRequired => 'Escribe tu fecha de nacimiento.';

  @override
  String get validationBirthDateInvalid =>
      'Escribe una fecha válida con el formato dd/mm/aaaa.';

  @override
  String validationBirthDateAge(int min, int max) {
    return 'Debes tener entre $min y $max años.';
  }

  @override
  String get validationFacultyRequired => 'Elige tu facultad.';

  @override
  String get validationProgramRequired => 'Elige tu carrera.';

  @override
  String get validationPhoneFormat =>
      'Escribe un celular de 10 dígitos que empiece por 3.';

  @override
  String validationPasswordLength(int minLength) {
    return 'Usa mínimo $minLength caracteres.';
  }

  @override
  String get validationPasswordLettersNumbers => 'Combina letras y números.';

  @override
  String get validationPasswordConfirmRequired => 'Repite tu contraseña.';

  @override
  String get validationPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get validationConsentRequired =>
      'Debes aceptar la autorización de datos para crear tu cuenta.';

  @override
  String get validationCodeFormat =>
      'Escribe el código de números que te enviamos.';

  @override
  String get errorInvalidCredentials => 'Correo o contraseña incorrectos.';

  @override
  String get errorEmailAlreadyInUse =>
      'Ya existe una cuenta con este correo. Inicia sesión o recupera tu contraseña.';

  @override
  String get errorUsernameTaken =>
      'Ese nombre de usuario ya está en uso. Prueba con otro.';

  @override
  String errorNonInstitutionalEmail(String domain) {
    return 'Solo se aceptan correos @$domain.';
  }

  @override
  String errorWeakPassword(int minLength) {
    return 'La contraseña debe tener mínimo $minLength caracteres, con letras y números.';
  }

  @override
  String get errorSamePassword =>
      'La contraseña nueva debe ser diferente a la anterior.';

  @override
  String get errorEmailNotVerified =>
      'Tu correo aún no está verificado. Escribe el código que te enviamos al registrarte; revisa también la carpeta de spam.';

  @override
  String get errorInvalidCode =>
      'El código no es válido o ya venció. Revísalo o pide uno nuevo.';

  @override
  String get errorEmailDelivery =>
      'No pudimos enviar el correo con el código. Inténtalo de nuevo en unos minutos.';

  @override
  String get errorTooManyRequests =>
      'Demasiados intentos. Espera unos minutos y vuelve a intentarlo.';

  @override
  String get errorNetwork =>
      'Sin conexión. Revisa tu internet y vuelve a intentarlo.';

  @override
  String get errorUnknown => 'No se pudo completar. Vuelve a intentarlo.';

  @override
  String get signOutButton => 'Cerrar sesión';

  @override
  String get navHome => 'Inicio';

  @override
  String get navGroups => 'Grupos';

  @override
  String get navCreate => 'Publicar';

  @override
  String get navMessages => 'Mensajes';

  @override
  String get navProfile => 'Perfil';

  @override
  String get feedFeatured => 'Destacados';

  @override
  String get feedCommunity => 'Comunidad';

  @override
  String get feedTransport => 'Transporte';

  @override
  String get feedFilterTooltip => 'Filtrar publicaciones';

  @override
  String get feedSearchTooltip => 'Buscar';

  @override
  String get feedFilterTitle => 'Filtrar por categoría';

  @override
  String get feedFilterAll => 'Todas';

  @override
  String feedFilterActive(String category) {
    return 'Mostrando: $category';
  }

  @override
  String get feedFilterClear => 'Quitar filtro';

  @override
  String get feedEmpty => 'Aún no hay publicaciones aquí.';

  @override
  String get feedEmptyFeatured => 'Aún no hay publicaciones destacadas.';

  @override
  String get feedError => 'No pudimos cargar las publicaciones.';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get categoryProduct => 'Producto';

  @override
  String get categoryService => 'Servicio';

  @override
  String get categorySkill => 'Habilidad';

  @override
  String get categoryAdvisory => 'Asesoría';

  @override
  String get postFeatured => 'Destacado';

  @override
  String get postVerified => 'Cuenta verificada';

  @override
  String get postOptionsTooltip => 'Opciones de la publicación';

  @override
  String get postHide => 'Ocultar publicación';

  @override
  String get postHideHint => 'No volverás a verla en tu inicio.';

  @override
  String get postHidden => 'Publicación ocultada.';

  @override
  String get postReport => 'Reportar publicación';

  @override
  String get postReportHint => 'Avísanos si es engañosa o inapropiada.';

  @override
  String get postReportTitle => '¿Por qué reportas esta publicación?';

  @override
  String get reportSpam => 'Spam o publicidad engañosa';

  @override
  String get reportInappropriate => 'Contenido inapropiado u ofensivo';

  @override
  String get reportFraud => 'Fraude o estafa';

  @override
  String get reportOther => 'Otro motivo';

  @override
  String get postReported => 'Gracias. Revisaremos esta publicación.';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get closeTooltip => 'Cerrar';

  @override
  String get postSeeMore => 'Ver más';

  @override
  String get postSeeLess => 'Ver menos';

  @override
  String get postNoRatings => 'Sin calificaciones aún';

  @override
  String postReviews(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reseñas',
      one: '1 reseña',
    );
    return '$_temp0';
  }

  @override
  String get postRequest => 'Solicitar';

  @override
  String get postChatTooltip => 'Enviar mensaje';

  @override
  String railFollow(String name) {
    return 'Seguir a $name';
  }

  @override
  String railFollowing(String name) {
    return 'Dejar de seguir a $name';
  }

  @override
  String get railLike => 'Me gusta';

  @override
  String get railSave => 'Guardar';

  @override
  String get railSaved => 'Guardado';

  @override
  String get railShare => 'Compartir';

  @override
  String shareText(String text, String author) {
    return '$text\n\n— $author, en UpcConecta';
  }

  @override
  String get shareCopied =>
      'Copiado. Ya puedes pegarlo donde quieras compartirlo.';

  @override
  String get mediaVideo => 'Video';

  @override
  String mediaCounter(int current, int total) {
    return '$current/$total';
  }

  @override
  String get timeNow => 'Ahora';

  @override
  String timeMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String timeHours(int hours) {
    return '$hours h';
  }

  @override
  String timeDays(int days) {
    return '$days d';
  }

  @override
  String get comingSoon => 'Disponible muy pronto.';

  @override
  String get transportTitle => 'Transporte compartido';

  @override
  String get transportMessage =>
      'Muy pronto podrás compartir viaje entre tu casa y la universidad, viendo la ubicación en tiempo real.';

  @override
  String get groupsTitle => 'Grupos';

  @override
  String get groupsMessage =>
      'Aquí verás tus grupos de estudio y de juegos, públicos o privados.';

  @override
  String get messagesTitle => 'Mensajes';

  @override
  String get messagesMessage =>
      'Aquí verás tus conversaciones con otros estudiantes y profesores.';

  @override
  String get createPostTitle => 'Nueva publicación';

  @override
  String get createPostVisibility => 'Visible para la comunidad UPC';

  @override
  String get createPostYou => 'Tú';

  @override
  String get createPostPreview => 'Vista previa';

  @override
  String get createPostPreviewTitle => 'Así se verá en el inicio';

  @override
  String get createPostCategoryTitle => '¿Qué vas a publicar? *';

  @override
  String get createPostCategoryHint =>
      'Elige la categoría; ayuda a que te encuentren con los filtros.';

  @override
  String get createPostCategoryRequired => 'Elige una categoría.';

  @override
  String get createPostTextTitle => 'Descripción *';

  @override
  String get createPostTextLabel => 'Cuéntale a la comunidad';

  @override
  String get createPostTextHint =>
      'Describe tu producto, servicio, habilidad o asesoría: qué incluye, horarios, dónde entregas…';

  @override
  String get createPostTextRequired => 'Escribe una descripción.';

  @override
  String get createPostMediaTitle => 'Fotos o video';

  @override
  String createPostMediaHint(int photos, int megabytes) {
    return 'Opcional. Hasta $photos fotos o 1 video corto (máximo $megabytes MB).';
  }

  @override
  String get createPostAddPhotos => 'Agregar fotos';

  @override
  String get createPostAddVideo => 'Agregar video';

  @override
  String get createPostRemoveMedia => 'Quitar';

  @override
  String createPostPhotosSkipped(int photos, int megabytes) {
    return 'Algunas fotos no se agregaron: máximo $photos fotos JPG, PNG o WEBP de hasta $megabytes MB.';
  }

  @override
  String get createPostVideoInvalid =>
      'Ese formato de video no se puede subir. Usa MP4, MOV o WEBM.';

  @override
  String createPostVideoTooLarge(int megabytes) {
    return 'El video pesa más de $megabytes MB. Elige uno más corto.';
  }

  @override
  String createPostVideoSize(String megabytes) {
    return 'Video · $megabytes MB';
  }

  @override
  String get createPostTagsTitle => 'Etiquetas';

  @override
  String createPostTagsHint(int count) {
    return 'Opcional. Hasta $count palabras clave para que te encuentren.';
  }

  @override
  String get createPostTagLabel => 'Nueva etiqueta';

  @override
  String get createPostTagHint => 'Ej.: Tecnología';

  @override
  String get createPostTagsFull => 'Ya tienes el máximo de etiquetas';

  @override
  String get createPostAddTag => 'Agregar etiqueta';

  @override
  String get createPostRemoveTag => 'Quitar etiqueta';

  @override
  String get createPostSubmit => 'Publicar';

  @override
  String get createPostPublishing => 'Publicando…';

  @override
  String get createPostUploadingHint =>
      'Subiendo tus archivos; no cierres la app.';

  @override
  String get createPostDone => '¡Listo! Tu publicación ya está en el inicio.';

  @override
  String get createPostDiscardTitle => '¿Descartar la publicación?';

  @override
  String get createPostDiscardMessage =>
      'Lo que escribiste y los archivos que elegiste se perderán.';

  @override
  String get createPostKeepEditing => 'Seguir editando';

  @override
  String get createPostDiscard => 'Descartar';

  @override
  String get postDelete => 'Eliminar publicación';

  @override
  String get postDeleteHint => 'Se borra para todos, con sus fotos o video.';

  @override
  String get postDeleteTitle => '¿Eliminar la publicación?';

  @override
  String get postDeleteMessage => 'Esta acción no se puede deshacer.';

  @override
  String get postDeleteConfirm => 'Eliminar';

  @override
  String get postDeleted => 'Publicación eliminada.';

  @override
  String get videoError => 'No se pudo reproducir el video.';

  @override
  String get videoPlay => 'Reproducir';

  @override
  String get errorNotFound =>
      'No encontramos lo que buscas. Puede que se haya borrado.';

  @override
  String get errorConflict => 'Ese dato ya está en uso. Prueba con otro.';

  @override
  String get saveButton => 'Guardar';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileMoreInfo => 'Ver más información';

  @override
  String get profileMoreOptions => 'Más opciones';

  @override
  String get profileFollowingCount => 'Siguiendo';

  @override
  String get profileFollowersCount => 'Seguidores';

  @override
  String get profileLikesCount => 'Me gusta';

  @override
  String profileLikesInfo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count me gusta',
      one: '1 me gusta',
    );
    return '$_temp0 en todas las publicaciones.';
  }

  @override
  String get profileFollow => 'Seguir';

  @override
  String get profileFollowing => 'Siguiendo';

  @override
  String get profileMessage => 'Mensaje';

  @override
  String get profileTabPosts => 'Publicaciones';

  @override
  String get profileTabSaved => 'Guardadas';

  @override
  String get profileTabLiked => 'Me encanta';

  @override
  String get profileTabShared => 'Compartidas';

  @override
  String get profileEmptyMyPosts =>
      'Aún no has publicado. Toca + para compartir lo que ofreces.';

  @override
  String get profileEmptyPosts => 'Esta persona aún no ha publicado.';

  @override
  String get profileEmptySaved =>
      'Las publicaciones que guardes aparecerán aquí. Solo tú las ves.';

  @override
  String get profileEmptyLiked =>
      'Las publicaciones que te gusten aparecerán aquí. Solo tú las ves.';

  @override
  String get profileEmptyShared =>
      'Las publicaciones que compartas aparecerán aquí. Solo tú las ves.';

  @override
  String get profileRole => 'Rol';

  @override
  String get roleStudent => 'Estudiante';

  @override
  String get roleTeacher => 'Profesor';

  @override
  String get roleAdmin => 'Administrador';

  @override
  String get profileRating => 'Calificación';

  @override
  String get profilePostsCount => 'Publicaciones';

  @override
  String get profileMemberSince => 'En UpcConecta desde';

  @override
  String get profileNotSet => 'Sin agregar';

  @override
  String get profileShare => 'Compartir perfil';

  @override
  String profileShareText(String name, String username) {
    return 'Mira el perfil de $name (@$username) en UpcConecta.';
  }

  @override
  String get profileSettings => 'Configuración y privacidad';

  @override
  String get profileReport => 'Reportar perfil';

  @override
  String get profileViewersTitle => 'Vistas del perfil';

  @override
  String get profileViewersHint =>
      'Personas que visitaron tu perfil en los últimos 30 días.';

  @override
  String get profileViewersEmpty =>
      'Nadie ha visitado tu perfil en los últimos 30 días.';

  @override
  String profileViewedAgo(String time) {
    return 'Visitó tu perfil · $time';
  }

  @override
  String get searchUsersTitle => 'Buscar personas';

  @override
  String get searchUsersFieldHint => 'Nombre o @usuario';

  @override
  String get searchUsersHint =>
      'Busca compañeros, amigos o profesores por su nombre o usuario.';

  @override
  String searchUsersEmpty(String query) {
    return 'No encontramos a nadie con «$query».';
  }

  @override
  String get followersEmpty => 'Aún no tiene seguidores.';

  @override
  String get followingEmpty => 'Aún no sigue a nadie.';

  @override
  String get signOutConfirmTitle => '¿Cerrar sesión?';

  @override
  String get signOutConfirmMessage =>
      'Tendrás que volver a escribir tu correo y contraseña para entrar.';

  @override
  String get editProfileBasicInfo => 'Información básica';

  @override
  String get editProfilePrivateInfo => 'Datos privados';

  @override
  String get editProfilePrivateHint =>
      'Tu correo y tu fecha de nacimiento solo los ves tú. El correo institucional no se puede cambiar.';

  @override
  String get editProfileBio => 'Descripción';

  @override
  String get editProfileAddBio => 'Agregar una descripción';

  @override
  String get editProfilePhone => 'Celular';

  @override
  String get editProfileAddPhone => 'Agregar celular';

  @override
  String get editProfileStudies => 'Facultad y carrera';

  @override
  String get editProfileAddStudies => 'Agregar tu carrera';

  @override
  String get profileSaved => 'Perfil actualizado.';

  @override
  String get profilePhotoSaved => 'Foto de perfil actualizada.';

  @override
  String get usernameAvailable => 'Disponible';

  @override
  String get startupErrorTitle => 'No pudimos abrir UpcConecta';

  @override
  String get startupErrorMessage =>
      'Revisa tu conexión a internet y vuelve a intentarlo. Si el problema sigue, cierra la app y ábrela de nuevo.';
}
