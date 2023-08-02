from PyPDF2 import PdfReader
import os

FINAL_FILE_NAME = "train_data.txt"

def load_pdf(path):
    reader = PdfReader(os.getcwd() + "/" + path)
    
    doc_text = []
    for page in reader.pages:
        page_text = page.extract_text()
        doc_text.append(page_text)

    # Append to final file
    print(os.getcwd())
    file = open(os.getcwd() + "/" + "../data/" + FINAL_FILE_NAME, "w", encoding="utf-8")
    file.writelines(doc_text)
    file.close()

    return None

