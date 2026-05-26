function fn() {
  var env = karate.env;
  karate.log('karate.env system property was:', env);
  if (!env) {
    env = 'dev';
  }
  var config = {
    env: env,
    baseUrl: 'https://app-circulosw-dev-back-01-gjdqdcbfc6ccarfh.eastus-01.azurewebsites.net/web-api-circles/1.0'
  };
  if (env == 'qa') {
    config.baseUrl = 'https://URL-DE-QA-PENDIENTE.com';
  } else if (env == 'prod') {
    config.baseUrl = 'https://URL-DE-PROD-PENDIENTE.com';
  }
  return config;
}