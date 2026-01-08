import '../models/country_model.dart';

const List<Map<String, dynamic>> countriesRawData = [
  {
    "name": "Afghanistan",
    "alpha2Code": "AF",
    "alpha3Code": "AFG",
    "callingCodes": [
      "93"
    ]
  },
  {
    "name": "\u00c5land Islands",
    "alpha2Code": "AX",
    "alpha3Code": "ALA",
    "callingCodes": [
      "358"
    ]
  },
  {
    "name": "Albania",
    "alpha2Code": "AL",
    "alpha3Code": "ALB",
    "callingCodes": [
      "355"
    ]
  },
  {
    "name": "Algeria",
    "alpha2Code": "DZ",
    "alpha3Code": "DZA",
    "callingCodes": [
      "213"
    ]
  },
  {
    "name": "American Samoa",
    "alpha2Code": "AS",
    "alpha3Code": "ASM",
    "callingCodes": [
      "1684"
    ]
  },
  {
    "name": "Andorra",
    "alpha2Code": "AD",
    "alpha3Code": "AND",
    "callingCodes": [
      "376"
    ]
  },
  {
    "name": "Angola",
    "alpha2Code": "AO",
    "alpha3Code": "AGO",
    "callingCodes": [
      "244"
    ]
  },
  {
    "name": "Anguilla",
    "alpha2Code": "AI",
    "alpha3Code": "AIA",
    "callingCodes": [
      "1264"
    ]
  },
  {
    "name": "Antarctica",
    "alpha2Code": "AQ",
    "alpha3Code": "ATA",
    "callingCodes": [
      "672"
    ]
  },
  {
    "name": "Antigua and Barbuda",
    "alpha2Code": "AG",
    "alpha3Code": "ATG",
    "callingCodes": [
      "1268"
    ]
  },
  {
    "name": "Argentina",
    "alpha2Code": "AR",
    "alpha3Code": "ARG",
    "callingCodes": [
      "54"
    ]
  },
  {
    "name": "Armenia",
    "alpha2Code": "AM",
    "alpha3Code": "ARM",
    "callingCodes": [
      "374"
    ]
  },
  {
    "name": "Aruba",
    "alpha2Code": "AW",
    "alpha3Code": "ABW",
    "callingCodes": [
      "297"
    ]
  },
  {
    "name": "Australia",
    "alpha2Code": "AU",
    "alpha3Code": "AUS",
    "callingCodes": [
      "61"
    ]
  },
  {
    "name": "Austria",
    "alpha2Code": "AT",
    "alpha3Code": "AUT",
    "callingCodes": [
      "43"
    ]
  },
  {
    "name": "Azerbaijan",
    "alpha2Code": "AZ",
    "alpha3Code": "AZE",
    "callingCodes": [
      "994"
    ]
  },
  {
    "name": "Bahamas",
    "alpha2Code": "BS",
    "alpha3Code": "BHS",
    "callingCodes": [
      "1242"
    ]
  },
  {
    "name": "Bahrain",
    "alpha2Code": "BH",
    "alpha3Code": "BHR",
    "callingCodes": [
      "973"
    ]
  },
  {
    "name": "Bangladesh",
    "alpha2Code": "BD",
    "alpha3Code": "BGD",
    "callingCodes": [
      "880"
    ]
  },
  {
    "name": "Barbados",
    "alpha2Code": "BB",
    "alpha3Code": "BRB",
    "callingCodes": [
      "1246"
    ]
  },
  {
    "name": "Belarus",
    "alpha2Code": "BY",
    "alpha3Code": "BLR",
    "callingCodes": [
      "375"
    ]
  },
  {
    "name": "Belgium",
    "alpha2Code": "BE",
    "alpha3Code": "BEL",
    "callingCodes": [
      "32"
    ]
  },
  {
    "name": "Belize",
    "alpha2Code": "BZ",
    "alpha3Code": "BLZ",
    "callingCodes": [
      "501"
    ]
  },
  {
    "name": "Benin",
    "alpha2Code": "BJ",
    "alpha3Code": "BEN",
    "callingCodes": [
      "229"
    ]
  },
  {
    "name": "Bermuda",
    "alpha2Code": "BM",
    "alpha3Code": "BMU",
    "callingCodes": [
      "1441"
    ]
  },
  {
    "name": "Bhutan",
    "alpha2Code": "BT",
    "alpha3Code": "BTN",
    "callingCodes": [
      "975"
    ]
  },
  {
    "name": "Bolivia (Plurinational State of)",
    "alpha2Code": "BO",
    "alpha3Code": "BOL",
    "callingCodes": [
      "591"
    ]
  },
  {
    "name": "Bonaire, Sint Eustatius and Saba",
    "alpha2Code": "BQ",
    "alpha3Code": "BES",
    "callingCodes": [
      "5997"
    ]
  },
  {
    "name": "Bosnia and Herzegovina",
    "alpha2Code": "BA",
    "alpha3Code": "BIH",
    "callingCodes": [
      "387"
    ]
  },
  {
    "name": "Botswana",
    "alpha2Code": "BW",
    "alpha3Code": "BWA",
    "callingCodes": [
      "267"
    ]
  },
  {
    "name": "Bouvet Island",
    "alpha2Code": "BV",
    "alpha3Code": "BVT",
    "callingCodes": [
      ""
    ]
  },
  {
    "name": "Brazil",
    "alpha2Code": "BR",
    "alpha3Code": "BRA",
    "callingCodes": [
      "55"
    ]
  },
  {
    "name": "British Indian Ocean Territory",
    "alpha2Code": "IO",
    "alpha3Code": "IOT",
    "callingCodes": [
      "246"
    ]
  },
  {
    "name": "United States Minor Outlying Islands",
    "alpha2Code": "UM",
    "alpha3Code": "UMI",
    "callingCodes": [
      ""
    ]
  },
  {
    "name": "Virgin Islands (British)",
    "alpha2Code": "VG",
    "alpha3Code": "VGB",
    "callingCodes": [
      "1284"
    ]
  },
  {
    "name": "Virgin Islands (U.S.)",
    "alpha2Code": "VI",
    "alpha3Code": "VIR",
    "callingCodes": [
      "1 340"
    ]
  },
  {
    "name": "Brunei Darussalam",
    "alpha2Code": "BN",
    "alpha3Code": "BRN",
    "callingCodes": [
      "673"
    ]
  },
  {
    "name": "Bulgaria",
    "alpha2Code": "BG",
    "alpha3Code": "BGR",
    "callingCodes": [
      "359"
    ]
  },
  {
    "name": "Burkina Faso",
    "alpha2Code": "BF",
    "alpha3Code": "BFA",
    "callingCodes": [
      "226"
    ]
  },
  {
    "name": "Burundi",
    "alpha2Code": "BI",
    "alpha3Code": "BDI",
    "callingCodes": [
      "257"
    ]
  },
  {
    "name": "Cambodia",
    "alpha2Code": "KH",
    "alpha3Code": "KHM",
    "callingCodes": [
      "855"
    ]
  },
  {
    "name": "Cameroon",
    "alpha2Code": "CM",
    "alpha3Code": "CMR",
    "callingCodes": [
      "237"
    ]
  },
  {
    "name": "Canada",
    "alpha2Code": "CA",
    "alpha3Code": "CAN",
    "callingCodes": [
      "1"
    ]
  },
  {
    "name": "Cabo Verde",
    "alpha2Code": "CV",
    "alpha3Code": "CPV",
    "callingCodes": [
      "238"
    ]
  },
  {
    "name": "Cayman Islands",
    "alpha2Code": "KY",
    "alpha3Code": "CYM",
    "callingCodes": [
      "1345"
    ]
  },
  {
    "name": "Central African Republic",
    "alpha2Code": "CF",
    "alpha3Code": "CAF",
    "callingCodes": [
      "236"
    ]
  },
  {
    "name": "Chad",
    "alpha2Code": "TD",
    "alpha3Code": "TCD",
    "callingCodes": [
      "235"
    ]
  },
  {
    "name": "Chile",
    "alpha2Code": "CL",
    "alpha3Code": "CHL",
    "callingCodes": [
      "56"
    ]
  },
  {
    "name": "China",
    "alpha2Code": "CN",
    "alpha3Code": "CHN",
    "callingCodes": [
      "86"
    ]
  },
  {
    "name": "Christmas Island",
    "alpha2Code": "CX",
    "alpha3Code": "CXR",
    "callingCodes": [
      "61"
    ]
  },
  {
    "name": "Cocos (Keeling) Islands",
    "alpha2Code": "CC",
    "alpha3Code": "CCK",
    "callingCodes": [
      "61"
    ]
  },
  {
    "name": "Colombia",
    "alpha2Code": "CO",
    "alpha3Code": "COL",
    "callingCodes": [
      "57"
    ]
  },
  {
    "name": "Comoros",
    "alpha2Code": "KM",
    "alpha3Code": "COM",
    "callingCodes": [
      "269"
    ]
  },
  {
    "name": "Congo",
    "alpha2Code": "CG",
    "alpha3Code": "COG",
    "callingCodes": [
      "242"
    ]
  },
  {
    "name": "Congo (Democratic Republic of the)",
    "alpha2Code": "CD",
    "alpha3Code": "COD",
    "callingCodes": [
      "243"
    ]
  },
  {
    "name": "Cook Islands",
    "alpha2Code": "CK",
    "alpha3Code": "COK",
    "callingCodes": [
      "682"
    ]
  },
  {
    "name": "Costa Rica",
    "alpha2Code": "CR",
    "alpha3Code": "CRI",
    "callingCodes": [
      "506"
    ]
  },
  {
    "name": "Croatia",
    "alpha2Code": "HR",
    "alpha3Code": "HRV",
    "callingCodes": [
      "385"
    ]
  },
  {
    "name": "Cuba",
    "alpha2Code": "CU",
    "alpha3Code": "CUB",
    "callingCodes": [
      "53"
    ]
  },
  {
    "name": "Cura\u00e7ao",
    "alpha2Code": "CW",
    "alpha3Code": "CUW",
    "callingCodes": [
      "599"
    ]
  },
  {
    "name": "Cyprus",
    "alpha2Code": "CY",
    "alpha3Code": "CYP",
    "callingCodes": [
      "357"
    ]
  },
  {
    "name": "Czech Republic",
    "alpha2Code": "CZ",
    "alpha3Code": "CZE",
    "callingCodes": [
      "420"
    ]
  },
  {
    "name": "Denmark",
    "alpha2Code": "DK",
    "alpha3Code": "DNK",
    "callingCodes": [
      "45"
    ]
  },
  {
    "name": "Djibouti",
    "alpha2Code": "DJ",
    "alpha3Code": "DJI",
    "callingCodes": [
      "253"
    ]
  },
  {
    "name": "Dominica",
    "alpha2Code": "DM",
    "alpha3Code": "DMA",
    "callingCodes": [
      "1767"
    ]
  },
  {
    "name": "Dominican Republic",
    "alpha2Code": "DO",
    "alpha3Code": "DOM",
    "callingCodes": [
      "1809",
      "1829",
      "1849"
    ]
  },
  {
    "name": "Ecuador",
    "alpha2Code": "EC",
    "alpha3Code": "ECU",
    "callingCodes": [
      "593"
    ]
  },
  {
    "name": "Egypt",
    "alpha2Code": "EG",
    "alpha3Code": "EGY",
    "callingCodes": [
      "20"
    ]
  },
  {
    "name": "El Salvador",
    "alpha2Code": "SV",
    "alpha3Code": "SLV",
    "callingCodes": [
      "503"
    ]
  },
  {
    "name": "Equatorial Guinea",
    "alpha2Code": "GQ",
    "alpha3Code": "GNQ",
    "callingCodes": [
      "240"
    ]
  },
  {
    "name": "Eritrea",
    "alpha2Code": "ER",
    "alpha3Code": "ERI",
    "callingCodes": [
      "291"
    ]
  },
  {
    "name": "Estonia",
    "alpha2Code": "EE",
    "alpha3Code": "EST",
    "callingCodes": [
      "372"
    ]
  },
  {
    "name": "Ethiopia",
    "alpha2Code": "ET",
    "alpha3Code": "ETH",
    "callingCodes": [
      "251"
    ]
  },
  {
    "name": "Falkland Islands (Malvinas)",
    "alpha2Code": "FK",
    "alpha3Code": "FLK",
    "callingCodes": [
      "500"
    ]
  },
  {
    "name": "Faroe Islands",
    "alpha2Code": "FO",
    "alpha3Code": "FRO",
    "callingCodes": [
      "298"
    ]
  },
  {
    "name": "Fiji",
    "alpha2Code": "FJ",
    "alpha3Code": "FJI",
    "callingCodes": [
      "679"
    ]
  },
  {
    "name": "Finland",
    "alpha2Code": "FI",
    "alpha3Code": "FIN",
    "callingCodes": [
      "358"
    ]
  },
  {
    "name": "France",
    "alpha2Code": "FR",
    "alpha3Code": "FRA",
    "callingCodes": [
      "33"
    ]
  },
  {
    "name": "French Guiana",
    "alpha2Code": "GF",
    "alpha3Code": "GUF",
    "callingCodes": [
      "594"
    ]
  },
  {
    "name": "French Polynesia",
    "alpha2Code": "PF",
    "alpha3Code": "PYF",
    "callingCodes": [
      "689"
    ]
  },
  {
    "name": "French Southern Territories",
    "alpha2Code": "TF",
    "alpha3Code": "ATF",
    "callingCodes": [
      ""
    ]
  },
  {
    "name": "Gabon",
    "alpha2Code": "GA",
    "alpha3Code": "GAB",
    "callingCodes": [
      "241"
    ]
  },
  {
    "name": "Gambia",
    "alpha2Code": "GM",
    "alpha3Code": "GMB",
    "callingCodes": [
      "220"
    ]
  },
  {
    "name": "Georgia",
    "alpha2Code": "GE",
    "alpha3Code": "GEO",
    "callingCodes": [
      "995"
    ]
  },
  {
    "name": "Germany",
    "alpha2Code": "DE",
    "alpha3Code": "DEU",
    "callingCodes": [
      "49"
    ]
  },
  {
    "name": "Ghana",
    "alpha2Code": "GH",
    "alpha3Code": "GHA",
    "callingCodes": [
      "233"
    ]
  },
  {
    "name": "Gibraltar",
    "alpha2Code": "GI",
    "alpha3Code": "GIB",
    "callingCodes": [
      "350"
    ]
  },
  {
    "name": "Greece",
    "alpha2Code": "GR",
    "alpha3Code": "GRC",
    "callingCodes": [
      "30"
    ]
  },
  {
    "name": "Greenland",
    "alpha2Code": "GL",
    "alpha3Code": "GRL",
    "callingCodes": [
      "299"
    ]
  },
  {
    "name": "Grenada",
    "alpha2Code": "GD",
    "alpha3Code": "GRD",
    "callingCodes": [
      "1473"
    ]
  },
  {
    "name": "Guadeloupe",
    "alpha2Code": "GP",
    "alpha3Code": "GLP",
    "callingCodes": [
      "590"
    ]
  },
  {
    "name": "Guam",
    "alpha2Code": "GU",
    "alpha3Code": "GUM",
    "callingCodes": [
      "1671"
    ]
  },
  {
    "name": "Guatemala",
    "alpha2Code": "GT",
    "alpha3Code": "GTM",
    "callingCodes": [
      "502"
    ]
  },
  {
    "name": "Guernsey",
    "alpha2Code": "GG",
    "alpha3Code": "GGY",
    "callingCodes": [
      "44"
    ]
  },
  {
    "name": "Guinea",
    "alpha2Code": "GN",
    "alpha3Code": "GIN",
    "callingCodes": [
      "224"
    ]
  },
  {
    "name": "Guinea-Bissau",
    "alpha2Code": "GW",
    "alpha3Code": "GNB",
    "callingCodes": [
      "245"
    ]
  },
  {
    "name": "Guyana",
    "alpha2Code": "GY",
    "alpha3Code": "GUY",
    "callingCodes": [
      "592"
    ]
  },
  {
    "name": "Haiti",
    "alpha2Code": "HT",
    "alpha3Code": "HTI",
    "callingCodes": [
      "509"
    ]
  },
  {
    "name": "Heard Island and McDonald Islands",
    "alpha2Code": "HM",
    "alpha3Code": "HMD",
    "callingCodes": [
      ""
    ]
  },
  {
    "name": "Holy See",
    "alpha2Code": "VA",
    "alpha3Code": "VAT",
    "callingCodes": [
      "379"
    ]
  },
  {
    "name": "Honduras",
    "alpha2Code": "HN",
    "alpha3Code": "HND",
    "callingCodes": [
      "504"
    ]
  },
  {
    "name": "Hong Kong",
    "alpha2Code": "HK",
    "alpha3Code": "HKG",
    "callingCodes": [
      "852"
    ]
  },
  {
    "name": "Hungary",
    "alpha2Code": "HU",
    "alpha3Code": "HUN",
    "callingCodes": [
      "36"
    ]
  },
  {
    "name": "Iceland",
    "alpha2Code": "IS",
    "alpha3Code": "ISL",
    "callingCodes": [
      "354"
    ]
  },
  {
    "name": "India",
    "alpha2Code": "IN",
    "alpha3Code": "IND",
    "callingCodes": [
      "91"
    ]
  },
  {
    "name": "Indonesia",
    "alpha2Code": "ID",
    "alpha3Code": "IDN",
    "callingCodes": [
      "62"
    ]
  },
  {
    "name": "C\u00f4te d'Ivoire",
    "alpha2Code": "CI",
    "alpha3Code": "CIV",
    "callingCodes": [
      "225"
    ]
  },
  {
    "name": "Iran (Islamic Republic of)",
    "alpha2Code": "IR",
    "alpha3Code": "IRN",
    "callingCodes": [
      "98"
    ]
  },
  {
    "name": "Iraq",
    "alpha2Code": "IQ",
    "alpha3Code": "IRQ",
    "callingCodes": [
      "964"
    ]
  },
  {
    "name": "Ireland",
    "alpha2Code": "IE",
    "alpha3Code": "IRL",
    "callingCodes": [
      "353"
    ]
  },
  {
    "name": "Isle of Man",
    "alpha2Code": "IM",
    "alpha3Code": "IMN",
    "callingCodes": [
      "44"
    ]
  },
  {
    "name": "Israel",
    "alpha2Code": "IL",
    "alpha3Code": "ISR",
    "callingCodes": [
      "972"
    ]
  },
  {
    "name": "Italy",
    "alpha2Code": "IT",
    "alpha3Code": "ITA",
    "callingCodes": [
      "39"
    ]
  },
  {
    "name": "Jamaica",
    "alpha2Code": "JM",
    "alpha3Code": "JAM",
    "callingCodes": [
      "1876"
    ]
  },
  {
    "name": "Japan",
    "alpha2Code": "JP",
    "alpha3Code": "JPN",
    "callingCodes": [
      "81"
    ]
  },
  {
    "name": "Jersey",
    "alpha2Code": "JE",
    "alpha3Code": "JEY",
    "callingCodes": [
      "44"
    ]
  },
  {
    "name": "Jordan",
    "alpha2Code": "JO",
    "alpha3Code": "JOR",
    "callingCodes": [
      "962"
    ]
  },
  {
    "name": "Kazakhstan",
    "alpha2Code": "KZ",
    "alpha3Code": "KAZ",
    "callingCodes": [
      "76",
      "77"
    ]
  },
  {
    "name": "Kenya",
    "alpha2Code": "KE",
    "alpha3Code": "KEN",
    "callingCodes": [
      "254"
    ]
  },
  {
    "name": "Kiribati",
    "alpha2Code": "KI",
    "alpha3Code": "KIR",
    "callingCodes": [
      "686"
    ]
  },
  {
    "name": "Kuwait",
    "alpha2Code": "KW",
    "alpha3Code": "KWT",
    "callingCodes": [
      "965"
    ]
  },
  {
    "name": "Kyrgyzstan",
    "alpha2Code": "KG",
    "alpha3Code": "KGZ",
    "callingCodes": [
      "996"
    ]
  },
  {
    "name": "Lao People's Democratic Republic",
    "alpha2Code": "LA",
    "alpha3Code": "LAO",
    "callingCodes": [
      "856"
    ]
  },
  {
    "name": "Latvia",
    "alpha2Code": "LV",
    "alpha3Code": "LVA",
    "callingCodes": [
      "371"
    ]
  },
  {
    "name": "Lebanon",
    "alpha2Code": "LB",
    "alpha3Code": "LBN",
    "callingCodes": [
      "961"
    ]
  },
  {
    "name": "Lesotho",
    "alpha2Code": "LS",
    "alpha3Code": "LSO",
    "callingCodes": [
      "266"
    ]
  },
  {
    "name": "Liberia",
    "alpha2Code": "LR",
    "alpha3Code": "LBR",
    "callingCodes": [
      "231"
    ]
  },
  {
    "name": "Libya",
    "alpha2Code": "LY",
    "alpha3Code": "LBY",
    "callingCodes": [
      "218"
    ]
  },
  {
    "name": "Liechtenstein",
    "alpha2Code": "LI",
    "alpha3Code": "LIE",
    "callingCodes": [
      "423"
    ]
  },
  {
    "name": "Lithuania",
    "alpha2Code": "LT",
    "alpha3Code": "LTU",
    "callingCodes": [
      "370"
    ]
  },
  {
    "name": "Luxembourg",
    "alpha2Code": "LU",
    "alpha3Code": "LUX",
    "callingCodes": [
      "352"
    ]
  },
  {
    "name": "Macao",
    "alpha2Code": "MO",
    "alpha3Code": "MAC",
    "callingCodes": [
      "853"
    ]
  },
  {
    "name": "Macedonia (the former Yugoslav Republic of)",
    "alpha2Code": "MK",
    "alpha3Code": "MKD",
    "callingCodes": [
      "389"
    ]
  },
  {
    "name": "Madagascar",
    "alpha2Code": "MG",
    "alpha3Code": "MDG",
    "callingCodes": [
      "261"
    ]
  },
  {
    "name": "Malawi",
    "alpha2Code": "MW",
    "alpha3Code": "MWI",
    "callingCodes": [
      "265"
    ]
  },
  {
    "name": "Malaysia",
    "alpha2Code": "MY",
    "alpha3Code": "MYS",
    "callingCodes": [
      "60"
    ]
  },
  {
    "name": "Maldives",
    "alpha2Code": "MV",
    "alpha3Code": "MDV",
    "callingCodes": [
      "960"
    ]
  },
  {
    "name": "Mali",
    "alpha2Code": "ML",
    "alpha3Code": "MLI",
    "callingCodes": [
      "223"
    ]
  },
  {
    "name": "Malta",
    "alpha2Code": "MT",
    "alpha3Code": "MLT",
    "callingCodes": [
      "356"
    ]
  },
  {
    "name": "Marshall Islands",
    "alpha2Code": "MH",
    "alpha3Code": "MHL",
    "callingCodes": [
      "692"
    ]
  },
  {
    "name": "Martinique",
    "alpha2Code": "MQ",
    "alpha3Code": "MTQ",
    "callingCodes": [
      "596"
    ]
  },
  {
    "name": "Mauritania",
    "alpha2Code": "MR",
    "alpha3Code": "MRT",
    "callingCodes": [
      "222"
    ]
  },
  {
    "name": "Mauritius",
    "alpha2Code": "MU",
    "alpha3Code": "MUS",
    "callingCodes": [
      "230"
    ]
  },
  {
    "name": "Mayotte",
    "alpha2Code": "YT",
    "alpha3Code": "MYT",
    "callingCodes": [
      "262"
    ]
  },
  {
    "name": "Mexico",
    "alpha2Code": "MX",
    "alpha3Code": "MEX",
    "callingCodes": [
      "52"
    ]
  },
  {
    "name": "Micronesia (Federated States of)",
    "alpha2Code": "FM",
    "alpha3Code": "FSM",
    "callingCodes": [
      "691"
    ]
  },
  {
    "name": "Moldova (Republic of)",
    "alpha2Code": "MD",
    "alpha3Code": "MDA",
    "callingCodes": [
      "373"
    ]
  },
  {
    "name": "Monaco",
    "alpha2Code": "MC",
    "alpha3Code": "MCO",
    "callingCodes": [
      "377"
    ]
  },
  {
    "name": "Mongolia",
    "alpha2Code": "MN",
    "alpha3Code": "MNG",
    "callingCodes": [
      "976"
    ]
  },
  {
    "name": "Montenegro",
    "alpha2Code": "ME",
    "alpha3Code": "MNE",
    "callingCodes": [
      "382"
    ]
  },
  {
    "name": "Montserrat",
    "alpha2Code": "MS",
    "alpha3Code": "MSR",
    "callingCodes": [
      "1664"
    ]
  },
  {
    "name": "Morocco",
    "alpha2Code": "MA",
    "alpha3Code": "MAR",
    "callingCodes": [
      "212"
    ]
  },
  {
    "name": "Mozambique",
    "alpha2Code": "MZ",
    "alpha3Code": "MOZ",
    "callingCodes": [
      "258"
    ]
  },
  {
    "name": "Myanmar",
    "alpha2Code": "MM",
    "alpha3Code": "MMR",
    "callingCodes": [
      "95"
    ]
  },
  {
    "name": "Namibia",
    "alpha2Code": "NA",
    "alpha3Code": "NAM",
    "callingCodes": [
      "264"
    ]
  },
  {
    "name": "Nauru",
    "alpha2Code": "NR",
    "alpha3Code": "NRU",
    "callingCodes": [
      "674"
    ]
  },
  {
    "name": "Nepal",
    "alpha2Code": "NP",
    "alpha3Code": "NPL",
    "callingCodes": [
      "977"
    ]
  },
  {
    "name": "Netherlands",
    "alpha2Code": "NL",
    "alpha3Code": "NLD",
    "callingCodes": [
      "31"
    ]
  },
  {
    "name": "New Caledonia",
    "alpha2Code": "NC",
    "alpha3Code": "NCL",
    "callingCodes": [
      "687"
    ]
  },
  {
    "name": "New Zealand",
    "alpha2Code": "NZ",
    "alpha3Code": "NZL",
    "callingCodes": [
      "64"
    ]
  },
  {
    "name": "Nicaragua",
    "alpha2Code": "NI",
    "alpha3Code": "NIC",
    "callingCodes": [
      "505"
    ]
  },
  {
    "name": "Niger",
    "alpha2Code": "NE",
    "alpha3Code": "NER",
    "callingCodes": [
      "227"
    ]
  },
  {
    "name": "Nigeria",
    "alpha2Code": "NG",
    "alpha3Code": "NGA",
    "callingCodes": [
      "234"
    ]
  },
  {
    "name": "Niue",
    "alpha2Code": "NU",
    "alpha3Code": "NIU",
    "callingCodes": [
      "683"
    ]
  },
  {
    "name": "Norfolk Island",
    "alpha2Code": "NF",
    "alpha3Code": "NFK",
    "callingCodes": [
      "672"
    ]
  },
  {
    "name": "Korea (Democratic People's Republic of)",
    "alpha2Code": "KP",
    "alpha3Code": "PRK",
    "callingCodes": [
      "850"
    ]
  },
  {
    "name": "Northern Mariana Islands",
    "alpha2Code": "MP",
    "alpha3Code": "MNP",
    "callingCodes": [
      "1670"
    ]
  },
  {
    "name": "Norway",
    "alpha2Code": "NO",
    "alpha3Code": "NOR",
    "callingCodes": [
      "47"
    ]
  },
  {
    "name": "Oman",
    "alpha2Code": "OM",
    "alpha3Code": "OMN",
    "callingCodes": [
      "968"
    ]
  },
  {
    "name": "Pakistan",
    "alpha2Code": "PK",
    "alpha3Code": "PAK",
    "callingCodes": [
      "92"
    ]
  },
  {
    "name": "Palau",
    "alpha2Code": "PW",
    "alpha3Code": "PLW",
    "callingCodes": [
      "680"
    ]
  },
  {
    "name": "Palestine, State of",
    "alpha2Code": "PS",
    "alpha3Code": "PSE",
    "callingCodes": [
      "970"
    ]
  },
  {
    "name": "Panama",
    "alpha2Code": "PA",
    "alpha3Code": "PAN",
    "callingCodes": [
      "507"
    ]
  },
  {
    "name": "Papua New Guinea",
    "alpha2Code": "PG",
    "alpha3Code": "PNG",
    "callingCodes": [
      "675"
    ]
  },
  {
    "name": "Paraguay",
    "alpha2Code": "PY",
    "alpha3Code": "PRY",
    "callingCodes": [
      "595"
    ]
  },
  {
    "name": "Peru",
    "alpha2Code": "PE",
    "alpha3Code": "PER",
    "callingCodes": [
      "51"
    ]
  },
  {
    "name": "Philippines",
    "alpha2Code": "PH",
    "alpha3Code": "PHL",
    "callingCodes": [
      "63"
    ]
  },
  {
    "name": "Pitcairn",
    "alpha2Code": "PN",
    "alpha3Code": "PCN",
    "callingCodes": [
      "64"
    ]
  },
  {
    "name": "Poland",
    "alpha2Code": "PL",
    "alpha3Code": "POL",
    "callingCodes": [
      "48"
    ]
  },
  {
    "name": "Portugal",
    "alpha2Code": "PT",
    "alpha3Code": "PRT",
    "callingCodes": [
      "351"
    ]
  },
  {
    "name": "Puerto Rico",
    "alpha2Code": "PR",
    "alpha3Code": "PRI",
    "callingCodes": [
      "1787",
      "1939"
    ]
  },
  {
    "name": "Qatar",
    "alpha2Code": "QA",
    "alpha3Code": "QAT",
    "callingCodes": [
      "974"
    ]
  },
  {
    "name": "Republic of Kosovo",
    "alpha2Code": "XK",
    "alpha3Code": "KOS",
    "callingCodes": [
      "383"
    ]
  },
  {
    "name": "R\u00e9union",
    "alpha2Code": "RE",
    "alpha3Code": "REU",
    "callingCodes": [
      "262"
    ]
  },
  {
    "name": "Romania",
    "alpha2Code": "RO",
    "alpha3Code": "ROU",
    "callingCodes": [
      "40"
    ]
  },
  {
    "name": "Russian Federation",
    "alpha2Code": "RU",
    "alpha3Code": "RUS",
    "callingCodes": [
      "7"
    ]
  },
  {
    "name": "Rwanda",
    "alpha2Code": "RW",
    "alpha3Code": "RWA",
    "callingCodes": [
      "250"
    ]
  },
  {
    "name": "Saint Barth\u00e9lemy",
    "alpha2Code": "BL",
    "alpha3Code": "BLM",
    "callingCodes": [
      "590"
    ]
  },
  {
    "name": "Saint Helena, Ascension and Tristan da Cunha",
    "alpha2Code": "SH",
    "alpha3Code": "SHN",
    "callingCodes": [
      "290"
    ]
  },
  {
    "name": "Saint Kitts and Nevis",
    "alpha2Code": "KN",
    "alpha3Code": "KNA",
    "callingCodes": [
      "1869"
    ]
  },
  {
    "name": "Saint Lucia",
    "alpha2Code": "LC",
    "alpha3Code": "LCA",
    "callingCodes": [
      "1758"
    ]
  },
  {
    "name": "Saint Martin (French part)",
    "alpha2Code": "MF",
    "alpha3Code": "MAF",
    "callingCodes": [
      "590"
    ]
  },
  {
    "name": "Saint Pierre and Miquelon",
    "alpha2Code": "PM",
    "alpha3Code": "SPM",
    "callingCodes": [
      "508"
    ]
  },
  {
    "name": "Saint Vincent and the Grenadines",
    "alpha2Code": "VC",
    "alpha3Code": "VCT",
    "callingCodes": [
      "1784"
    ]
  },
  {
    "name": "Samoa",
    "alpha2Code": "WS",
    "alpha3Code": "WSM",
    "callingCodes": [
      "685"
    ]
  },
  {
    "name": "San Marino",
    "alpha2Code": "SM",
    "alpha3Code": "SMR",
    "callingCodes": [
      "378"
    ]
  },
  {
    "name": "Sao Tome and Principe",
    "alpha2Code": "ST",
    "alpha3Code": "STP",
    "callingCodes": [
      "239"
    ]
  },
  {
    "name": "Saudi Arabia",
    "alpha2Code": "SA",
    "alpha3Code": "SAU",
    "callingCodes": [
      "966"
    ]
  },
  {
    "name": "Senegal",
    "alpha2Code": "SN",
    "alpha3Code": "SEN",
    "callingCodes": [
      "221"
    ]
  },
  {
    "name": "Serbia",
    "alpha2Code": "RS",
    "alpha3Code": "SRB",
    "callingCodes": [
      "381"
    ]
  },
  {
    "name": "Seychelles",
    "alpha2Code": "SC",
    "alpha3Code": "SYC",
    "callingCodes": [
      "248"
    ]
  },
  {
    "name": "Sierra Leone",
    "alpha2Code": "SL",
    "alpha3Code": "SLE",
    "callingCodes": [
      "232"
    ]
  },
  {
    "name": "Singapore",
    "alpha2Code": "SG",
    "alpha3Code": "SGP",
    "callingCodes": [
      "65"
    ]
  },
  {
    "name": "Sint Maarten (Dutch part)",
    "alpha2Code": "SX",
    "alpha3Code": "SXM",
    "callingCodes": [
      "1721"
    ]
  },
  {
    "name": "Slovakia",
    "alpha2Code": "SK",
    "alpha3Code": "SVK",
    "callingCodes": [
      "421"
    ]
  },
  {
    "name": "Slovenia",
    "alpha2Code": "SI",
    "alpha3Code": "SVN",
    "callingCodes": [
      "386"
    ]
  },
  {
    "name": "Solomon Islands",
    "alpha2Code": "SB",
    "alpha3Code": "SLB",
    "callingCodes": [
      "677"
    ]
  },
  {
    "name": "Somalia",
    "alpha2Code": "SO",
    "alpha3Code": "SOM",
    "callingCodes": [
      "252"
    ]
  },
  {
    "name": "South Africa",
    "alpha2Code": "ZA",
    "alpha3Code": "ZAF",
    "callingCodes": [
      "27"
    ]
  },
  {
    "name": "South Georgia and the South Sandwich Islands",
    "alpha2Code": "GS",
    "alpha3Code": "SGS",
    "callingCodes": [
      "500"
    ]
  },
  {
    "name": "Korea (Republic of)",
    "alpha2Code": "KR",
    "alpha3Code": "KOR",
    "callingCodes": [
      "82"
    ]
  },
  {
    "name": "South Sudan",
    "alpha2Code": "SS",
    "alpha3Code": "SSD",
    "callingCodes": [
      "211"
    ]
  },
  {
    "name": "Spain",
    "alpha2Code": "ES",
    "alpha3Code": "ESP",
    "callingCodes": [
      "34"
    ]
  },
  {
    "name": "Sri Lanka",
    "alpha2Code": "LK",
    "alpha3Code": "LKA",
    "callingCodes": [
      "94"
    ]
  },
  {
    "name": "Sudan",
    "alpha2Code": "SD",
    "alpha3Code": "SDN",
    "callingCodes": [
      "249"
    ]
  },
  {
    "name": "Suriname",
    "alpha2Code": "SR",
    "alpha3Code": "SUR",
    "callingCodes": [
      "597"
    ]
  },
  {
    "name": "Svalbard and Jan Mayen",
    "alpha2Code": "SJ",
    "alpha3Code": "SJM",
    "callingCodes": [
      "4779"
    ]
  },
  {
    "name": "Swaziland",
    "alpha2Code": "SZ",
    "alpha3Code": "SWZ",
    "callingCodes": [
      "268"
    ]
  },
  {
    "name": "Sweden",
    "alpha2Code": "SE",
    "alpha3Code": "SWE",
    "callingCodes": [
      "46"
    ]
  },
  {
    "name": "Switzerland",
    "alpha2Code": "CH",
    "alpha3Code": "CHE",
    "callingCodes": [
      "41"
    ]
  },
  {
    "name": "Syrian Arab Republic",
    "alpha2Code": "SY",
    "alpha3Code": "SYR",
    "callingCodes": [
      "963"
    ]
  },
  {
    "name": "Taiwan",
    "alpha2Code": "TW",
    "alpha3Code": "TWN",
    "callingCodes": [
      "886"
    ]
  },
  {
    "name": "Tajikistan",
    "alpha2Code": "TJ",
    "alpha3Code": "TJK",
    "callingCodes": [
      "992"
    ]
  },
  {
    "name": "Tanzania, United Republic of",
    "alpha2Code": "TZ",
    "alpha3Code": "TZA",
    "callingCodes": [
      "255"
    ]
  },
  {
    "name": "Thailand",
    "alpha2Code": "TH",
    "alpha3Code": "THA",
    "callingCodes": [
      "66"
    ]
  },
  {
    "name": "Timor-Leste",
    "alpha2Code": "TL",
    "alpha3Code": "TLS",
    "callingCodes": [
      "670"
    ]
  },
  {
    "name": "Togo",
    "alpha2Code": "TG",
    "alpha3Code": "TGO",
    "callingCodes": [
      "228"
    ]
  },
  {
    "name": "Tokelau",
    "alpha2Code": "TK",
    "alpha3Code": "TKL",
    "callingCodes": [
      "690"
    ]
  },
  {
    "name": "Tonga",
    "alpha2Code": "TO",
    "alpha3Code": "TON",
    "callingCodes": [
      "676"
    ]
  },
  {
    "name": "Trinidad and Tobago",
    "alpha2Code": "TT",
    "alpha3Code": "TTO",
    "callingCodes": [
      "1868"
    ]
  },
  {
    "name": "Tunisia",
    "alpha2Code": "TN",
    "alpha3Code": "TUN",
    "callingCodes": [
      "216"
    ]
  },
  {
    "name": "Turkey",
    "alpha2Code": "TR",
    "alpha3Code": "TUR",
    "callingCodes": [
      "90"
    ]
  },
  {
    "name": "Turkmenistan",
    "alpha2Code": "TM",
    "alpha3Code": "TKM",
    "callingCodes": [
      "993"
    ]
  },
  {
    "name": "Turks and Caicos Islands",
    "alpha2Code": "TC",
    "alpha3Code": "TCA",
    "callingCodes": [
      "1649"
    ]
  },
  {
    "name": "Tuvalu",
    "alpha2Code": "TV",
    "alpha3Code": "TUV",
    "callingCodes": [
      "688"
    ]
  },
  {
    "name": "Uganda",
    "alpha2Code": "UG",
    "alpha3Code": "UGA",
    "callingCodes": [
      "256"
    ]
  },
  {
    "name": "Ukraine",
    "alpha2Code": "UA",
    "alpha3Code": "UKR",
    "callingCodes": [
      "380"
    ]
  },
  {
    "name": "United Arab Emirates",
    "alpha2Code": "AE",
    "alpha3Code": "ARE",
    "callingCodes": [
      "971"
    ]
  },
  {
    "name": "United Kingdom of Great Britain and Northern Ireland",
    "alpha2Code": "GB",
    "alpha3Code": "GBR",
    "callingCodes": [
      "44"
    ]
  },
  {
    "name": "United States of America",
    "alpha2Code": "US",
    "alpha3Code": "USA",
    "callingCodes": [
      "1"
    ]
  },
  {
    "name": "Uruguay",
    "alpha2Code": "UY",
    "alpha3Code": "URY",
    "callingCodes": [
      "598"
    ]
  },
  {
    "name": "Uzbekistan",
    "alpha2Code": "UZ",
    "alpha3Code": "UZB",
    "callingCodes": [
      "998"
    ]
  },
  {
    "name": "Vanuatu",
    "alpha2Code": "VU",
    "alpha3Code": "VUT",
    "callingCodes": [
      "678"
    ]
  },
  {
    "name": "Venezuela (Bolivarian Republic of)",
    "alpha2Code": "VE",
    "alpha3Code": "VEN",
    "callingCodes": [
      "58"
    ]
  },
  {
    "name": "Viet Nam",
    "alpha2Code": "VN",
    "alpha3Code": "VNM",
    "callingCodes": [
      "84"
    ]
  },
  {
    "name": "Wallis and Futuna",
    "alpha2Code": "WF",
    "alpha3Code": "WLF",
    "callingCodes": [
      "681"
    ]
  },
  {
    "name": "Western Sahara",
    "alpha2Code": "EH",
    "alpha3Code": "ESH",
    "callingCodes": [
      "212"
    ]
  },
  {
    "name": "Yemen",
    "alpha2Code": "YE",
    "alpha3Code": "YEM",
    "callingCodes": [
      "967"
    ]
  },
  {
    "name": "Zambia",
    "alpha2Code": "ZM",
    "alpha3Code": "ZMB",
    "callingCodes": [
      "260"
    ]
  },
  {
    "name": "Zimbabwe",
    "alpha2Code": "ZW",
    "alpha3Code": "ZWE",
    "callingCodes": [
      "263"
    ]
  }
];

final List<Country> allCountries = countriesRawData.map((e) => Country.fromMap(e)).toList();
