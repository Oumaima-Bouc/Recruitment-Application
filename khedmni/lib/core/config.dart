// Simple runtime config. Can be overridden at build time with --dart-define=EMAIL_SERVICE_URL=<url>
const String kEmailServiceUrl = String.fromEnvironment(
  'EMAIL_SERVICE_URL',
  // Use local IP for physical device to reach host machine
  defaultValue: 'http://10.211.193.254:3000', 
);
