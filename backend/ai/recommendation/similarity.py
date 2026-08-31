import math
from typing import List, Dict, Any

def get_product_text(product: Dict[str, Any]) -> str:
    """
    Combine product fields to create a single string representing the product
    for TF-IDF vectorization.
    """
    category = product.get("category", "")
    name = product.get("name", "")
    description = product.get("description", "")
    tags = " ".join(product.get("tags", []))
    
    return f"{category} {name} {description} {tags}".strip().lower()

def compute_tf(text: str) -> Dict[str, float]:
    """
    Compute Term Frequency (TF) for a given text.
    """
    words = text.split()
    tf_dict = {}
    if not words:
        return tf_dict
    
    word_count = len(words)
    for word in words:
        tf_dict[word] = tf_dict.get(word, 0) + 1
        
    for word in tf_dict:
        tf_dict[word] = tf_dict[word] / float(word_count)
        
    return tf_dict

def compute_idf(documents: List[str]) -> Dict[str, float]:
    """
    Compute Inverse Document Frequency (IDF) across a list of documents.
    """
    N = len(documents)
    idf_dict = {}
    
    # Count number of documents containing each word
    document_word_counts = {}
    for doc in documents:
        words = set(doc.split())
        for word in words:
            document_word_counts[word] = document_word_counts.get(word, 0) + 1
            
    for word, count in document_word_counts.items():
        idf_dict[word] = math.log10(N / float(count)) if count > 0 else 0
        
    return idf_dict

def compute_tfidf(tf: Dict[str, float], idf: Dict[str, float]) -> Dict[str, float]:
    """
    Compute TF-IDF score.
    """
    tfidf = {}
    for word, val in tf.items():
        tfidf[word] = val * idf.get(word, 0.0)
    return tfidf

def cosine_similarity(vec1: Dict[str, float], vec2: Dict[str, float]) -> float:
    """
    Compute cosine similarity between two TF-IDF vectors.
    """
    intersection = set(vec1.keys()) & set(vec2.keys())
    numerator = sum([vec1[x] * vec2[x] for x in intersection])

    sum1 = sum([vec1[x]**2 for x in vec1.keys()])
    sum2 = sum([vec2[x]**2 for x in vec2.keys()])
    denominator = math.sqrt(sum1) * math.sqrt(sum2)

    if not denominator:
        return 0.0
    else:
        return float(numerator) / denominator

def calculate_product_similarity(target_product: Dict[str, Any], reference_products: List[Dict[str, Any]]) -> float:
    """
    Calculate the max similarity between a target product and a list of reference products (like a cart or past purchases).
    Returns a normalized score between 0.0 and 1.0.
    """
    if not reference_products:
        return 0.0
        
    target_text = get_product_text(target_product)
    ref_texts = [get_product_text(p) for p in reference_products]
    
    all_texts = [target_text] + ref_texts
    
    idf = compute_idf(all_texts)
    
    target_tf = compute_tf(target_text)
    target_tfidf = compute_tfidf(target_tf, idf)
    
    max_sim = 0.0
    for ref_text in ref_texts:
        ref_tf = compute_tf(ref_text)
        ref_tfidf = compute_tfidf(ref_tf, idf)
        
        sim = cosine_similarity(target_tfidf, ref_tfidf)
        if sim > max_sim:
            max_sim = sim
            
    return max_sim
