/**
 * Filtro de groserías y lenguaje ofensivo
 * Compatible con español, inglés y otros idiomas.
 * Incluye normalización para detectar variantes como:
 * w3on, f.u.c.k, p*ta, ctm, ql, weeeon, etc.
 */

const badWords = new Set([
  // Español
  'mierda',
  'puta',
  'puto',
  'cabron',
  'cabrón',
  'pendejo',
  'pendeja',
  'pendejete',
  'idiota',
  'estupido',
  'estúpido',
  'estupida',
  'estúpida',
  'imbecil',
  'imbécil',
  'concha',
  'verga',
  'joder',
  'coño',
  'maricon',
  'maricón',
  'marica',
  'zorra',
  'perra',

  // Chile
  'weon',
  'weón',
  'huevon',
  'huevón',
  'aweonao',
  'aweonada',
  'culiao',
  'culiado',
  'culiao',
  'culia',
  'conchetumare',
  'conchetumadre',
  'ctm',
  'ql',
  'qlo',
  'saco wea',
  'sacowea',
  'wea',
  'huea',
  'wn',
  'wna',
  'maraco',
  'longi',

  // Argentina / Uruguay
  'boludo',
  'boluda',
  'pelotudo',
  'pelotuda',
  'forro',
  'forra',
  'tarado',
  'tarada',
  'salame',
  'gil',
  'gila',
  'orto',

  // México
  'chingada',
  'chingar',
  'chingado',
  'pinche',
  'culero',
  'culera',
  'mamon',
  'mamón',
  'puñetas',

  // España
  'gilipollas',
  'hostia',
  'capullo',
  'capulla',
  'subnormal',
  'pringao',
  'pringada',

  // Colombia
  'gonorrea',
  'careverga',
  'carechimba',
  'malparido',
  'malparida',
  'hijueputa',
  'guevon',
  'guevón',

  // Venezuela
  'mamaguevo',
  'jalabolas',
  'gafo',
  'coñazo',

  // Perú
  'cojudo',
  'cojuda',
  'huevonazo',
  'baboso',
  'babosa',

  // Ecuador
  'longo',
  'caretuco',

  // Generales
  'culo',
  'mierdoso',
  'mierdosa',
  'bastardo',
  'bastarda',
  'desgraciado',
  'desgraciada',
  'maldito',
  'maldita',
  'hijo puta',
  'hija puta',
  'hijo de puta',
  'hija de puta',
  'hijo de perra',
  'hija de perra',
  'cerdo',
  'cerda',
  'payaso',
  'payasa',

  // Inglés
  'fuck',
  'fucking',
  'fucker',
  'motherfucker',
  'shit',
  'bullshit',
  'asshole',
  'bitch',
  'son of a bitch',
  'bastard',
  'dick',
  'douchebag',
  'jerk',
  'wanker',
  'prick',
  'slut',
  'whore',
  'retard',
  'moron',
  'idiot',
  'stupid',

  // Portugués
  'caralho',
  'porra',
  'merda',
  'filho da puta',
  'babaca',
  'otario',
  'otário',

  // Francés
  'merde',
  'connard',
  'connasse',
  'salope',
  'encule',
  'enculé',
  'putain',
  'batard',
  'bâtard',

  // Italiano
  'cazzo',
  'stronzo',
  'stronza',
  'vaffanculo',
  'puttana',

  // Alemán
  'scheisse',
  'scheiße',
  'arschloch',
  'hurensohn',
  'mistkerl',

  // Ruso
  'blyat',
  'suka',
  'pidor',
  'mudak',
  'debil',

  // Polaco
  'kurwa',
  'skurwysyn',

  // Turco
  'orospu',
  'pic',
  'siktir',
  'aptal',

  // Árabe (transliterado)
  'sharmuta',
  'ibn kalb',
  'ahmaq',

  // Hindi
  'madarchod',
  'bhenchod',
  'chutiya',
  'harami',
  'gandu',

  // Indonesio
  'anjing',
  'bangsat',
  'kontol',
  'memek',

  // Filipino
  'putangina',
  'gago',
  'ulol',
  'tarantado',

  // Japonés
  'baka',
  'aho',
  'kuso',

  // Coreano
  'ssibal',
  'saekki',
  'byeongsin',

  // Chino
  'shabi',
  'cao ni ma',
  'wangba'
])

function normalizeText(text: string): string {
  return text
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[@]/g, 'a')
    .replace(/[3]/g, 'e')
    .replace(/[1!]/g, 'i')
    .replace(/[0]/g, 'o')
    .replace(/[5$]/g, 's')
    .replace(/[7]/g, 't')
    .replace(/[^a-z0-9\s]/g, '')
    .replace(/(.)\1{2,}/g, '$1')
}

const profanityRegex = new RegExp(
  `\\b(?:${Array.from(badWords)
    .map(word =>
      normalizeText(word).replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    )
    .sort((a, b) => b.length - a.length)
    .join('|')})\\b`,
  'iu'
)

const obfuscatedPatterns = [
  /f+u+c+k+/i,
  /s+h+i+t+/i,
  /p+u+t+a+/i,
  /p+u+t+o+/i,
  /c+a+b+r+o+n+/i,
  /p+e+n+d+e+j+o+/i,
  /w+e+o+n+/i,
  /h+u+e+v+o+n+/i,
  /c+t+m+/i,
  /q+l+/i,
  /q+l+o+/i,
  /c+u+l+i+a+o+/i,
  /c+o+n+c+h+e+t+u+m+a+r+e+/i,
  /g+i+l+i+p+o+l+l+a+s+/i,
  /c+h+i+n+g+a+d+/i,
  /m+a+l+p+a+r+i+d+/i,
  /g+o+n+o+r+r+e+a+/i,
  /m+a+m+a+g+u+e+v+/i,
  /b+o+l+u+d+/i,
  /p+e+l+o+t+u+d+/i
]

export function containsProfanity(text: string): boolean {
  if (!text) return false

  const normalized = normalizeText(text)

  if (profanityRegex.test(normalized)) {
    return true
  }

  return obfuscatedPatterns.some(pattern => pattern.test(normalized))
}

export function sanitizeText(text: string): string {
  if (!text) return ''

  let sanitized = text

  for (const word of badWords) {
    const escapedWord = word.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')

    sanitized = sanitized.replace(
      new RegExp(`\\b${escapedWord}\\b`, 'giu'),
      match => '*'.repeat(match.length)
    )
  }

  return sanitized
}

export function getProfanityMatches(text: string): string[] {
  if (!text) return []

  const normalized = normalizeText(text)

  return Array.from(badWords).filter(word =>
    normalized.includes(normalizeText(word))
  )
}