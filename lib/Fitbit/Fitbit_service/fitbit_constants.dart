const String clientId = ''; //輸入你的API KEY
const String clientSecret = ''; 
const String redirectUri = 'https://localhost';

const String authUrl =
    'https://www.fitbit.com/oauth2/authorize?response_type=code&client_id=$clientId&redirect_uri=$redirectUri&scope=activity+cardio_fitness+electrocardiogram+heartrate+irregular_rhythm_notifications+location+nutrition+oxygen_saturation+profile+respiratory_rate+settings+sleep+social+temperature+weight';
