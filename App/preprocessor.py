import re
from langdetect import detect, LangDetectException


# ── Chunking ──────────────────────────────────────────────────
CHUNK_SIZE   = 256   # tokens par chunk
CHUNK_OVERLAP = 50   # chevauchement pour ne pas couper une idée


def chunk_text(text: str, chunk_size: int = CHUNK_SIZE, overlap: int = CHUNK_OVERLAP) -> list[str]:
    """
    Découpe le texte en chunks de `chunk_size` mots avec un chevauchement.
    Utilise les mots comme unité (approximation rapide des tokens XLM-R).
    Retourne toujours au moins un chunk.
    """
    words = text.split()
    if not words:
        return [""]

    chunks = []
    start  = 0
    while start < len(words):
        end = start + chunk_size
        chunks.append(" ".join(words[start:end]))
        if end >= len(words):
            break
        start = end - overlap   # reculer de `overlap` mots

    return chunks if chunks else [text]


def detect_language(text: str) -> str:
    """
    Détecte la langue du texte brut.
    Retourne 'fr', 'ar', 'en', ou 'unknown'.
    """
    try:
        clean = text.strip()
        if not clean or len(clean) < 20:
            return "unknown"
        lang = detect(clean)
        return lang
    except LangDetectException:
        return "unknown"


def get_clean_text(text: str) -> str:
    """
    Nettoyage léger adapté pour XLM-R
    Préserve les caractères arabes et latins accentués.
    """
    # Espaces multiples
    text = re.sub(r'\s+', ' ', text)

    # Retire les caractères hors alphabet latin étendu, arabe, et espaces
    text = re.sub(r'[^\w\sÀ-ÿ\u0600-\u06FF]', ' ', text)

    # Minuscules (n'affecte pas l'arabe)
    text = text.lower()

    return text.strip()