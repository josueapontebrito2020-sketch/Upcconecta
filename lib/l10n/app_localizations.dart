import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'UpcConecta'**
  String get appName;

  /// No description provided for @logoLabel.
  ///
  /// In es, this message translates to:
  /// **'Logo de UPC Conecta'**
  String get logoLabel;

  /// No description provided for @backTooltip.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get backTooltip;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Usa tu correo institucional de la UPC.'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo institucional'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'nombre@unicesar.edu.co'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// No description provided for @showPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get hidePassword;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get forgotPasswordLink;

  /// No description provided for @signInButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get signInButton;

  /// No description provided for @noAccountQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Aún no tienes cuenta?'**
  String get noAccountQuestion;

  /// No description provided for @createAccountLink.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccountLink;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Solo para estudiantes y profesores con correo @{domain}.'**
  String registerSubtitle(String domain);

  /// No description provided for @photoAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto de perfil'**
  String get photoAdd;

  /// No description provided for @photoChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get photoChange;

  /// No description provided for @photoRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto'**
  String get photoRemove;

  /// No description provided for @photoFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get photoFromGallery;

  /// No description provided for @photoFromCamera.
  ///
  /// In es, this message translates to:
  /// **'Tomar una foto'**
  String get photoFromCamera;

  /// No description provided for @photoOptional.
  ///
  /// In es, this message translates to:
  /// **'Opcional'**
  String get photoOptional;

  /// No description provided for @photoTooLarge.
  ///
  /// In es, this message translates to:
  /// **'La foto pesa más de 2 MB. Elige otra.'**
  String get photoTooLarge;

  /// No description provided for @photoInvalidType.
  ///
  /// In es, this message translates to:
  /// **'Usa una foto JPG, PNG o WEBP.'**
  String get photoInvalidType;

  /// No description provided for @fullNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get fullNameLabel;

  /// No description provided for @usernameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario'**
  String get usernameLabel;

  /// No description provided for @usernameHelper.
  ///
  /// In es, this message translates to:
  /// **'Así te encontrarán. Solo minúsculas, números, punto o guion bajo.'**
  String get usernameHelper;

  /// No description provided for @birthDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de nacimiento'**
  String get birthDateLabel;

  /// No description provided for @birthDateHint.
  ///
  /// In es, this message translates to:
  /// **'dd/mm/aaaa'**
  String get birthDateHint;

  /// No description provided for @birthDateCalendarTooltip.
  ///
  /// In es, this message translates to:
  /// **'Abrir calendario'**
  String get birthDateCalendarTooltip;

  /// No description provided for @facultyLabel.
  ///
  /// In es, this message translates to:
  /// **'Facultad'**
  String get facultyLabel;

  /// No description provided for @programLabel.
  ///
  /// In es, this message translates to:
  /// **'Carrera'**
  String get programLabel;

  /// No description provided for @programHintNoFaculty.
  ///
  /// In es, this message translates to:
  /// **'Primero elige tu facultad'**
  String get programHintNoFaculty;

  /// No description provided for @academicLoadError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la lista.'**
  String get academicLoadError;

  /// No description provided for @phoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Celular (opcional)'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In es, this message translates to:
  /// **'3001234567'**
  String get phoneHint;

  /// No description provided for @bioLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get bioLabel;

  /// No description provided for @bioHint.
  ///
  /// In es, this message translates to:
  /// **'Cuéntale a la comunidad qué sabes hacer o qué ofreces.'**
  String get bioHint;

  /// No description provided for @newPasswordHelper.
  ///
  /// In es, this message translates to:
  /// **'Mínimo {minLength} caracteres, con letras y números.'**
  String newPasswordHelper(int minLength);

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPasswordLabel;

  /// No description provided for @dataConsent.
  ///
  /// In es, this message translates to:
  /// **'Autorizo el tratamiento de mis datos personales según la Ley 1581 de 2012.'**
  String get dataConsent;

  /// No description provided for @createAccountButton.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get createAccountButton;

  /// No description provided for @haveAccountQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get haveAccountQuestion;

  /// No description provided for @verifyTitle.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu correo'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Enviamos un código a {email}. Escríbelo aquí para activar tu cuenta.'**
  String verifySubtitle(String email);

  /// No description provided for @verifyNoPending.
  ///
  /// In es, this message translates to:
  /// **'No hay un registro en curso. Crea tu cuenta para recibir un código.'**
  String get verifyNoPending;

  /// No description provided for @codeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de verificación'**
  String get codeLabel;

  /// No description provided for @checkSpam.
  ///
  /// In es, this message translates to:
  /// **'¿No te llegó? Revisa la carpeta de spam o pide otro código.'**
  String get checkSpam;

  /// No description provided for @verifyButton.
  ///
  /// In es, this message translates to:
  /// **'Verificar'**
  String get verifyButton;

  /// No description provided for @resendCodeButton.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get resendCodeButton;

  /// No description provided for @codeResent.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un código nuevo.'**
  String get codeResent;

  /// No description provided for @forgotTitle.
  ///
  /// In es, this message translates to:
  /// **'Recupera tu contraseña'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo institucional y te enviaremos un código para crear una contraseña nueva.'**
  String get forgotSubtitle;

  /// No description provided for @sendCodeButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get sendCodeButton;

  /// No description provided for @resetTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea una contraseña nueva'**
  String get resetTitle;

  /// No description provided for @resetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Escribe el código que enviamos a {email} y tu contraseña nueva.'**
  String resetSubtitle(String email);

  /// No description provided for @resetNoPending.
  ///
  /// In es, this message translates to:
  /// **'Primero pide un código con tu correo institucional.'**
  String get resetNoPending;

  /// No description provided for @newPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña nueva'**
  String get newPasswordLabel;

  /// No description provided for @resetButton.
  ///
  /// In es, this message translates to:
  /// **'Cambiar contraseña'**
  String get resetButton;

  /// No description provided for @validationEmailRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo institucional.'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailIncomplete.
  ///
  /// In es, this message translates to:
  /// **'Escribe el correo completo, por ejemplo nombre@{domain}.'**
  String validationEmailIncomplete(String domain);

  /// No description provided for @validationEmailNotInstitutional.
  ///
  /// In es, this message translates to:
  /// **'Usa tu correo institucional @{domain}.'**
  String validationEmailNotInstitutional(String domain);

  /// No description provided for @validationPasswordRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu contraseña.'**
  String get validationPasswordRequired;

  /// No description provided for @validationFullNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu nombre completo.'**
  String get validationFullNameRequired;

  /// No description provided for @validationFullNameIncomplete.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu nombre y apellido.'**
  String get validationFullNameIncomplete;

  /// No description provided for @validationUsernameRequired.
  ///
  /// In es, this message translates to:
  /// **'Elige un nombre de usuario.'**
  String get validationUsernameRequired;

  /// No description provided for @validationUsernameFormat.
  ///
  /// In es, this message translates to:
  /// **'Usa de {min} a {max} caracteres: minúsculas, números, punto o guion bajo.'**
  String validationUsernameFormat(int min, int max);

  /// No description provided for @validationBirthDateRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu fecha de nacimiento.'**
  String get validationBirthDateRequired;

  /// No description provided for @validationBirthDateInvalid.
  ///
  /// In es, this message translates to:
  /// **'Escribe una fecha válida con el formato dd/mm/aaaa.'**
  String get validationBirthDateInvalid;

  /// No description provided for @validationBirthDateAge.
  ///
  /// In es, this message translates to:
  /// **'Debes tener entre {min} y {max} años.'**
  String validationBirthDateAge(int min, int max);

  /// No description provided for @validationFacultyRequired.
  ///
  /// In es, this message translates to:
  /// **'Elige tu facultad.'**
  String get validationFacultyRequired;

  /// No description provided for @validationProgramRequired.
  ///
  /// In es, this message translates to:
  /// **'Elige tu carrera.'**
  String get validationProgramRequired;

  /// No description provided for @validationPhoneFormat.
  ///
  /// In es, this message translates to:
  /// **'Escribe un celular de 10 dígitos que empiece por 3.'**
  String get validationPhoneFormat;

  /// No description provided for @validationPasswordLength.
  ///
  /// In es, this message translates to:
  /// **'Usa mínimo {minLength} caracteres.'**
  String validationPasswordLength(int minLength);

  /// No description provided for @validationPasswordLettersNumbers.
  ///
  /// In es, this message translates to:
  /// **'Combina letras y números.'**
  String get validationPasswordLettersNumbers;

  /// No description provided for @validationPasswordConfirmRequired.
  ///
  /// In es, this message translates to:
  /// **'Repite tu contraseña.'**
  String get validationPasswordConfirmRequired;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get validationPasswordMismatch;

  /// No description provided for @validationConsentRequired.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar la autorización de datos para crear tu cuenta.'**
  String get validationConsentRequired;

  /// No description provided for @validationCodeFormat.
  ///
  /// In es, this message translates to:
  /// **'Escribe el código de números que te enviamos.'**
  String get validationCodeFormat;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailAlreadyInUse.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con este correo. Inicia sesión o recupera tu contraseña.'**
  String get errorEmailAlreadyInUse;

  /// No description provided for @errorUsernameTaken.
  ///
  /// In es, this message translates to:
  /// **'Ese nombre de usuario ya está en uso. Prueba con otro.'**
  String get errorUsernameTaken;

  /// No description provided for @errorNonInstitutionalEmail.
  ///
  /// In es, this message translates to:
  /// **'Solo se aceptan correos @{domain}.'**
  String errorNonInstitutionalEmail(String domain);

  /// No description provided for @errorWeakPassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener mínimo {minLength} caracteres, con letras y números.'**
  String errorWeakPassword(int minLength);

  /// No description provided for @errorSamePassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña nueva debe ser diferente a la anterior.'**
  String get errorSamePassword;

  /// No description provided for @errorEmailNotVerified.
  ///
  /// In es, this message translates to:
  /// **'Tu correo aún no está verificado. Escribe el código que te enviamos al registrarte; revisa también la carpeta de spam.'**
  String get errorEmailNotVerified;

  /// No description provided for @errorInvalidCode.
  ///
  /// In es, this message translates to:
  /// **'El código no es válido o ya venció. Revísalo o pide uno nuevo.'**
  String get errorInvalidCode;

  /// No description provided for @errorEmailDelivery.
  ///
  /// In es, this message translates to:
  /// **'No pudimos enviar el correo con el código. Inténtalo de nuevo en unos minutos.'**
  String get errorEmailDelivery;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera unos minutos y vuelve a intentarlo.'**
  String get errorTooManyRequests;

  /// No description provided for @errorNetwork.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión. Revisa tu internet y vuelve a intentarlo.'**
  String get errorNetwork;

  /// No description provided for @errorUnknown.
  ///
  /// In es, this message translates to:
  /// **'No se pudo completar. Vuelve a intentarlo.'**
  String get errorUnknown;

  /// No description provided for @signOutButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get signOutButton;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navGroups.
  ///
  /// In es, this message translates to:
  /// **'Grupos'**
  String get navGroups;

  /// No description provided for @navCreate.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get navCreate;

  /// No description provided for @navMessages.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get navMessages;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @feedFeatured.
  ///
  /// In es, this message translates to:
  /// **'Destacados'**
  String get feedFeatured;

  /// No description provided for @feedCommunity.
  ///
  /// In es, this message translates to:
  /// **'Comunidad'**
  String get feedCommunity;

  /// No description provided for @feedTransport.
  ///
  /// In es, this message translates to:
  /// **'Transporte'**
  String get feedTransport;

  /// No description provided for @feedFilterTooltip.
  ///
  /// In es, this message translates to:
  /// **'Filtrar publicaciones'**
  String get feedFilterTooltip;

  /// No description provided for @feedSearchTooltip.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get feedSearchTooltip;

  /// No description provided for @feedFilterTitle.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por categoría'**
  String get feedFilterTitle;

  /// No description provided for @feedFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todas'**
  String get feedFilterAll;

  /// No description provided for @feedFilterActive.
  ///
  /// In es, this message translates to:
  /// **'Mostrando: {category}'**
  String feedFilterActive(String category);

  /// No description provided for @feedFilterClear.
  ///
  /// In es, this message translates to:
  /// **'Quitar filtro'**
  String get feedFilterClear;

  /// No description provided for @feedEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay publicaciones aquí.'**
  String get feedEmpty;

  /// No description provided for @feedEmptyFeatured.
  ///
  /// In es, this message translates to:
  /// **'Aún no hay publicaciones destacadas.'**
  String get feedEmptyFeatured;

  /// No description provided for @feedError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las publicaciones.'**
  String get feedError;

  /// No description provided for @retryButton.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retryButton;

  /// No description provided for @categoryProduct.
  ///
  /// In es, this message translates to:
  /// **'Producto'**
  String get categoryProduct;

  /// No description provided for @categoryService.
  ///
  /// In es, this message translates to:
  /// **'Servicio'**
  String get categoryService;

  /// No description provided for @categorySkill.
  ///
  /// In es, this message translates to:
  /// **'Habilidad'**
  String get categorySkill;

  /// No description provided for @categoryAdvisory.
  ///
  /// In es, this message translates to:
  /// **'Asesoría'**
  String get categoryAdvisory;

  /// No description provided for @postFeatured.
  ///
  /// In es, this message translates to:
  /// **'Destacado'**
  String get postFeatured;

  /// No description provided for @postVerified.
  ///
  /// In es, this message translates to:
  /// **'Cuenta verificada'**
  String get postVerified;

  /// No description provided for @postOptionsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Opciones de la publicación'**
  String get postOptionsTooltip;

  /// No description provided for @postHide.
  ///
  /// In es, this message translates to:
  /// **'Ocultar publicación'**
  String get postHide;

  /// No description provided for @postHideHint.
  ///
  /// In es, this message translates to:
  /// **'No volverás a verla en tu inicio.'**
  String get postHideHint;

  /// No description provided for @postHidden.
  ///
  /// In es, this message translates to:
  /// **'Publicación ocultada.'**
  String get postHidden;

  /// No description provided for @postReport.
  ///
  /// In es, this message translates to:
  /// **'Reportar publicación'**
  String get postReport;

  /// No description provided for @postReportHint.
  ///
  /// In es, this message translates to:
  /// **'Avísanos si es engañosa o inapropiada.'**
  String get postReportHint;

  /// No description provided for @postReportTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué reportas esta publicación?'**
  String get postReportTitle;

  /// No description provided for @reportSpam.
  ///
  /// In es, this message translates to:
  /// **'Spam o publicidad engañosa'**
  String get reportSpam;

  /// No description provided for @reportInappropriate.
  ///
  /// In es, this message translates to:
  /// **'Contenido inapropiado u ofensivo'**
  String get reportInappropriate;

  /// No description provided for @reportFraud.
  ///
  /// In es, this message translates to:
  /// **'Fraude o estafa'**
  String get reportFraud;

  /// No description provided for @reportOther.
  ///
  /// In es, this message translates to:
  /// **'Otro motivo'**
  String get reportOther;

  /// No description provided for @postReported.
  ///
  /// In es, this message translates to:
  /// **'Gracias. Revisaremos esta publicación.'**
  String get postReported;

  /// No description provided for @cancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelButton;

  /// No description provided for @closeTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get closeTooltip;

  /// No description provided for @postSeeMore.
  ///
  /// In es, this message translates to:
  /// **'Ver más'**
  String get postSeeMore;

  /// No description provided for @postSeeLess.
  ///
  /// In es, this message translates to:
  /// **'Ver menos'**
  String get postSeeLess;

  /// No description provided for @postNoRatings.
  ///
  /// In es, this message translates to:
  /// **'Sin calificaciones aún'**
  String get postNoRatings;

  /// No description provided for @postReviews.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 reseña} other{{count} reseñas}}'**
  String postReviews(int count);

  /// No description provided for @postRequest.
  ///
  /// In es, this message translates to:
  /// **'Solicitar'**
  String get postRequest;

  /// No description provided for @postChatTooltip.
  ///
  /// In es, this message translates to:
  /// **'Enviar mensaje'**
  String get postChatTooltip;

  /// No description provided for @railFollow.
  ///
  /// In es, this message translates to:
  /// **'Seguir a {name}'**
  String railFollow(String name);

  /// No description provided for @railFollowing.
  ///
  /// In es, this message translates to:
  /// **'Dejar de seguir a {name}'**
  String railFollowing(String name);

  /// No description provided for @railLike.
  ///
  /// In es, this message translates to:
  /// **'Me gusta'**
  String get railLike;

  /// No description provided for @railSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get railSave;

  /// No description provided for @railSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardado'**
  String get railSaved;

  /// No description provided for @railShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get railShare;

  /// No description provided for @shareText.
  ///
  /// In es, this message translates to:
  /// **'{text}\n\n— {author}, en UpcConecta'**
  String shareText(String text, String author);

  /// No description provided for @shareCopied.
  ///
  /// In es, this message translates to:
  /// **'Copiado. Ya puedes pegarlo donde quieras compartirlo.'**
  String get shareCopied;

  /// No description provided for @mediaVideo.
  ///
  /// In es, this message translates to:
  /// **'Video'**
  String get mediaVideo;

  /// No description provided for @mediaCounter.
  ///
  /// In es, this message translates to:
  /// **'{current}/{total}'**
  String mediaCounter(int current, int total);

  /// No description provided for @timeNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get timeNow;

  /// No description provided for @timeMinutes.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min'**
  String timeMinutes(int minutes);

  /// No description provided for @timeHours.
  ///
  /// In es, this message translates to:
  /// **'{hours} h'**
  String timeHours(int hours);

  /// No description provided for @timeDays.
  ///
  /// In es, this message translates to:
  /// **'{days} d'**
  String timeDays(int days);

  /// No description provided for @comingSoon.
  ///
  /// In es, this message translates to:
  /// **'Disponible muy pronto.'**
  String get comingSoon;

  /// No description provided for @transportTitle.
  ///
  /// In es, this message translates to:
  /// **'Transporte compartido'**
  String get transportTitle;

  /// No description provided for @transportMessage.
  ///
  /// In es, this message translates to:
  /// **'Muy pronto podrás compartir viaje entre tu casa y la universidad, viendo la ubicación en tiempo real.'**
  String get transportMessage;

  /// No description provided for @groupsTitle.
  ///
  /// In es, this message translates to:
  /// **'Grupos'**
  String get groupsTitle;

  /// No description provided for @groupsMessage.
  ///
  /// In es, this message translates to:
  /// **'Aquí verás tus grupos de estudio y de juegos, públicos o privados.'**
  String get groupsMessage;

  /// No description provided for @messagesTitle.
  ///
  /// In es, this message translates to:
  /// **'Mensajes'**
  String get messagesTitle;

  /// No description provided for @messagesMessage.
  ///
  /// In es, this message translates to:
  /// **'Aquí verás tus conversaciones con otros estudiantes y profesores.'**
  String get messagesMessage;

  /// No description provided for @createPostTitle.
  ///
  /// In es, this message translates to:
  /// **'Nueva publicación'**
  String get createPostTitle;

  /// No description provided for @createPostVisibility.
  ///
  /// In es, this message translates to:
  /// **'Visible para la comunidad UPC'**
  String get createPostVisibility;

  /// No description provided for @createPostYou.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get createPostYou;

  /// No description provided for @createPostPreview.
  ///
  /// In es, this message translates to:
  /// **'Vista previa'**
  String get createPostPreview;

  /// No description provided for @createPostPreviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Así se verá en el inicio'**
  String get createPostPreviewTitle;

  /// No description provided for @createPostCategoryTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué vas a publicar? *'**
  String get createPostCategoryTitle;

  /// No description provided for @createPostCategoryHint.
  ///
  /// In es, this message translates to:
  /// **'Elige la categoría; ayuda a que te encuentren con los filtros.'**
  String get createPostCategoryHint;

  /// No description provided for @createPostCategoryRequired.
  ///
  /// In es, this message translates to:
  /// **'Elige una categoría.'**
  String get createPostCategoryRequired;

  /// No description provided for @createPostTextTitle.
  ///
  /// In es, this message translates to:
  /// **'Descripción *'**
  String get createPostTextTitle;

  /// No description provided for @createPostTextLabel.
  ///
  /// In es, this message translates to:
  /// **'Cuéntale a la comunidad'**
  String get createPostTextLabel;

  /// No description provided for @createPostTextHint.
  ///
  /// In es, this message translates to:
  /// **'Describe tu producto, servicio, habilidad o asesoría: qué incluye, horarios, dónde entregas…'**
  String get createPostTextHint;

  /// No description provided for @createPostTextRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe una descripción.'**
  String get createPostTextRequired;

  /// No description provided for @createPostMediaTitle.
  ///
  /// In es, this message translates to:
  /// **'Fotos o video'**
  String get createPostMediaTitle;

  /// No description provided for @createPostMediaHint.
  ///
  /// In es, this message translates to:
  /// **'Opcional. Hasta {photos} fotos o 1 video corto (máximo {megabytes} MB).'**
  String createPostMediaHint(int photos, int megabytes);

  /// No description provided for @createPostAddPhotos.
  ///
  /// In es, this message translates to:
  /// **'Agregar fotos'**
  String get createPostAddPhotos;

  /// No description provided for @createPostAddVideo.
  ///
  /// In es, this message translates to:
  /// **'Agregar video'**
  String get createPostAddVideo;

  /// No description provided for @createPostRemoveMedia.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get createPostRemoveMedia;

  /// No description provided for @createPostPhotosSkipped.
  ///
  /// In es, this message translates to:
  /// **'Algunas fotos no se agregaron: máximo {photos} fotos JPG, PNG o WEBP de hasta {megabytes} MB.'**
  String createPostPhotosSkipped(int photos, int megabytes);

  /// No description provided for @createPostVideoInvalid.
  ///
  /// In es, this message translates to:
  /// **'Ese formato de video no se puede subir. Usa MP4, MOV o WEBM.'**
  String get createPostVideoInvalid;

  /// No description provided for @createPostVideoTooLarge.
  ///
  /// In es, this message translates to:
  /// **'El video pesa más de {megabytes} MB. Elige uno más corto.'**
  String createPostVideoTooLarge(int megabytes);

  /// No description provided for @createPostVideoSize.
  ///
  /// In es, this message translates to:
  /// **'Video · {megabytes} MB'**
  String createPostVideoSize(String megabytes);

  /// No description provided for @createPostTagsTitle.
  ///
  /// In es, this message translates to:
  /// **'Etiquetas'**
  String get createPostTagsTitle;

  /// No description provided for @createPostTagsHint.
  ///
  /// In es, this message translates to:
  /// **'Opcional. Hasta {count} palabras clave para que te encuentren.'**
  String createPostTagsHint(int count);

  /// No description provided for @createPostTagLabel.
  ///
  /// In es, this message translates to:
  /// **'Nueva etiqueta'**
  String get createPostTagLabel;

  /// No description provided for @createPostTagHint.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Tecnología'**
  String get createPostTagHint;

  /// No description provided for @createPostTagsFull.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes el máximo de etiquetas'**
  String get createPostTagsFull;

  /// No description provided for @createPostAddTag.
  ///
  /// In es, this message translates to:
  /// **'Agregar etiqueta'**
  String get createPostAddTag;

  /// No description provided for @createPostRemoveTag.
  ///
  /// In es, this message translates to:
  /// **'Quitar etiqueta'**
  String get createPostRemoveTag;

  /// No description provided for @createPostSubmit.
  ///
  /// In es, this message translates to:
  /// **'Publicar'**
  String get createPostSubmit;

  /// No description provided for @createPostPublishing.
  ///
  /// In es, this message translates to:
  /// **'Publicando…'**
  String get createPostPublishing;

  /// No description provided for @createPostUploadingHint.
  ///
  /// In es, this message translates to:
  /// **'Subiendo tus archivos; no cierres la app.'**
  String get createPostUploadingHint;

  /// No description provided for @createPostDone.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Tu publicación ya está en el inicio.'**
  String get createPostDone;

  /// No description provided for @createPostDiscardTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Descartar la publicación?'**
  String get createPostDiscardTitle;

  /// No description provided for @createPostDiscardMessage.
  ///
  /// In es, this message translates to:
  /// **'Lo que escribiste y los archivos que elegiste se perderán.'**
  String get createPostDiscardMessage;

  /// No description provided for @createPostKeepEditing.
  ///
  /// In es, this message translates to:
  /// **'Seguir editando'**
  String get createPostKeepEditing;

  /// No description provided for @createPostDiscard.
  ///
  /// In es, this message translates to:
  /// **'Descartar'**
  String get createPostDiscard;

  /// No description provided for @postDelete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar publicación'**
  String get postDelete;

  /// No description provided for @postDeleteHint.
  ///
  /// In es, this message translates to:
  /// **'Se borra para todos, con sus fotos o video.'**
  String get postDeleteHint;

  /// No description provided for @postDeleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar la publicación?'**
  String get postDeleteTitle;

  /// No description provided for @postDeleteMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta acción no se puede deshacer.'**
  String get postDeleteMessage;

  /// No description provided for @postDeleteConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get postDeleteConfirm;

  /// No description provided for @postDeleted.
  ///
  /// In es, this message translates to:
  /// **'Publicación eliminada.'**
  String get postDeleted;

  /// No description provided for @videoError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reproducir el video.'**
  String get videoError;

  /// No description provided for @videoPlay.
  ///
  /// In es, this message translates to:
  /// **'Reproducir'**
  String get videoPlay;

  /// No description provided for @errorNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos lo que buscas. Puede que se haya borrado.'**
  String get errorNotFound;

  /// No description provided for @errorConflict.
  ///
  /// In es, this message translates to:
  /// **'Ese dato ya está en uso. Prueba con otro.'**
  String get errorConflict;

  /// No description provided for @saveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get saveButton;

  /// No description provided for @profileEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get profileEdit;

  /// No description provided for @profileMoreInfo.
  ///
  /// In es, this message translates to:
  /// **'Ver más información'**
  String get profileMoreInfo;

  /// No description provided for @profileMoreOptions.
  ///
  /// In es, this message translates to:
  /// **'Más opciones'**
  String get profileMoreOptions;

  /// No description provided for @profileFollowingCount.
  ///
  /// In es, this message translates to:
  /// **'Siguiendo'**
  String get profileFollowingCount;

  /// No description provided for @profileFollowersCount.
  ///
  /// In es, this message translates to:
  /// **'Seguidores'**
  String get profileFollowersCount;

  /// No description provided for @profileLikesCount.
  ///
  /// In es, this message translates to:
  /// **'Me gusta'**
  String get profileLikesCount;

  /// No description provided for @profileLikesInfo.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 me gusta} other{{count} me gusta}} en todas las publicaciones.'**
  String profileLikesInfo(int count);

  /// No description provided for @profileFollow.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get profileFollow;

  /// No description provided for @profileFollowing.
  ///
  /// In es, this message translates to:
  /// **'Siguiendo'**
  String get profileFollowing;

  /// No description provided for @profileMessage.
  ///
  /// In es, this message translates to:
  /// **'Mensaje'**
  String get profileMessage;

  /// No description provided for @profileTabPosts.
  ///
  /// In es, this message translates to:
  /// **'Publicaciones'**
  String get profileTabPosts;

  /// No description provided for @profileTabSaved.
  ///
  /// In es, this message translates to:
  /// **'Guardadas'**
  String get profileTabSaved;

  /// No description provided for @profileTabLiked.
  ///
  /// In es, this message translates to:
  /// **'Me encanta'**
  String get profileTabLiked;

  /// No description provided for @profileTabShared.
  ///
  /// In es, this message translates to:
  /// **'Compartidas'**
  String get profileTabShared;

  /// No description provided for @profileEmptyMyPosts.
  ///
  /// In es, this message translates to:
  /// **'Aún no has publicado. Toca + para compartir lo que ofreces.'**
  String get profileEmptyMyPosts;

  /// No description provided for @profileEmptyPosts.
  ///
  /// In es, this message translates to:
  /// **'Esta persona aún no ha publicado.'**
  String get profileEmptyPosts;

  /// No description provided for @profileEmptySaved.
  ///
  /// In es, this message translates to:
  /// **'Las publicaciones que guardes aparecerán aquí. Solo tú las ves.'**
  String get profileEmptySaved;

  /// No description provided for @profileEmptyLiked.
  ///
  /// In es, this message translates to:
  /// **'Las publicaciones que te gusten aparecerán aquí. Solo tú las ves.'**
  String get profileEmptyLiked;

  /// No description provided for @profileEmptyShared.
  ///
  /// In es, this message translates to:
  /// **'Las publicaciones que compartas aparecerán aquí. Solo tú las ves.'**
  String get profileEmptyShared;

  /// No description provided for @profileRole.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get profileRole;

  /// No description provided for @roleStudent.
  ///
  /// In es, this message translates to:
  /// **'Estudiante'**
  String get roleStudent;

  /// No description provided for @roleTeacher.
  ///
  /// In es, this message translates to:
  /// **'Profesor'**
  String get roleTeacher;

  /// No description provided for @roleAdmin.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get roleAdmin;

  /// No description provided for @profileRating.
  ///
  /// In es, this message translates to:
  /// **'Calificación'**
  String get profileRating;

  /// No description provided for @profilePostsCount.
  ///
  /// In es, this message translates to:
  /// **'Publicaciones'**
  String get profilePostsCount;

  /// No description provided for @profileMemberSince.
  ///
  /// In es, this message translates to:
  /// **'En UpcConecta desde'**
  String get profileMemberSince;

  /// No description provided for @profileNotSet.
  ///
  /// In es, this message translates to:
  /// **'Sin agregar'**
  String get profileNotSet;

  /// No description provided for @profileShare.
  ///
  /// In es, this message translates to:
  /// **'Compartir perfil'**
  String get profileShare;

  /// No description provided for @profileShareText.
  ///
  /// In es, this message translates to:
  /// **'Mira el perfil de {name} (@{username}) en UpcConecta.'**
  String profileShareText(String name, String username);

  /// No description provided for @profileSettings.
  ///
  /// In es, this message translates to:
  /// **'Configuración y privacidad'**
  String get profileSettings;

  /// No description provided for @profileReport.
  ///
  /// In es, this message translates to:
  /// **'Reportar perfil'**
  String get profileReport;

  /// No description provided for @profileViewersTitle.
  ///
  /// In es, this message translates to:
  /// **'Vistas del perfil'**
  String get profileViewersTitle;

  /// No description provided for @profileViewersHint.
  ///
  /// In es, this message translates to:
  /// **'Personas que visitaron tu perfil en los últimos 30 días.'**
  String get profileViewersHint;

  /// No description provided for @profileViewersEmpty.
  ///
  /// In es, this message translates to:
  /// **'Nadie ha visitado tu perfil en los últimos 30 días.'**
  String get profileViewersEmpty;

  /// No description provided for @profileViewedAgo.
  ///
  /// In es, this message translates to:
  /// **'Visitó tu perfil · {time}'**
  String profileViewedAgo(String time);

  /// No description provided for @searchUsersTitle.
  ///
  /// In es, this message translates to:
  /// **'Buscar personas'**
  String get searchUsersTitle;

  /// No description provided for @searchUsersFieldHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre o @usuario'**
  String get searchUsersFieldHint;

  /// No description provided for @searchUsersHint.
  ///
  /// In es, this message translates to:
  /// **'Busca compañeros, amigos o profesores por su nombre o usuario.'**
  String get searchUsersHint;

  /// No description provided for @searchUsersEmpty.
  ///
  /// In es, this message translates to:
  /// **'No encontramos a nadie con «{query}».'**
  String searchUsersEmpty(String query);

  /// No description provided for @followersEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no tiene seguidores.'**
  String get followersEmpty;

  /// No description provided for @followingEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no sigue a nadie.'**
  String get followingEmpty;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'Tendrás que volver a escribir tu correo y contraseña para entrar.'**
  String get signOutConfirmMessage;

  /// No description provided for @editProfileBasicInfo.
  ///
  /// In es, this message translates to:
  /// **'Información básica'**
  String get editProfileBasicInfo;

  /// No description provided for @editProfilePrivateInfo.
  ///
  /// In es, this message translates to:
  /// **'Datos privados'**
  String get editProfilePrivateInfo;

  /// No description provided for @editProfilePrivateHint.
  ///
  /// In es, this message translates to:
  /// **'Tu correo y tu fecha de nacimiento solo los ves tú. El correo institucional no se puede cambiar.'**
  String get editProfilePrivateHint;

  /// No description provided for @editProfileBio.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get editProfileBio;

  /// No description provided for @editProfileAddBio.
  ///
  /// In es, this message translates to:
  /// **'Agregar una descripción'**
  String get editProfileAddBio;

  /// No description provided for @editProfilePhone.
  ///
  /// In es, this message translates to:
  /// **'Celular'**
  String get editProfilePhone;

  /// No description provided for @editProfileAddPhone.
  ///
  /// In es, this message translates to:
  /// **'Agregar celular'**
  String get editProfileAddPhone;

  /// No description provided for @editProfileStudies.
  ///
  /// In es, this message translates to:
  /// **'Facultad y carrera'**
  String get editProfileStudies;

  /// No description provided for @editProfileAddStudies.
  ///
  /// In es, this message translates to:
  /// **'Agregar tu carrera'**
  String get editProfileAddStudies;

  /// No description provided for @profileSaved.
  ///
  /// In es, this message translates to:
  /// **'Perfil actualizado.'**
  String get profileSaved;

  /// No description provided for @profilePhotoSaved.
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil actualizada.'**
  String get profilePhotoSaved;

  /// No description provided for @usernameAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible'**
  String get usernameAvailable;

  /// No description provided for @startupErrorTitle.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir UpcConecta'**
  String get startupErrorTitle;

  /// No description provided for @startupErrorMessage.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión a internet y vuelve a intentarlo. Si el problema sigue, cierra la app y ábrela de nuevo.'**
  String get startupErrorMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
