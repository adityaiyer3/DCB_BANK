import os
from langchain.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.llms import OpenAI
from langchain.chains import RetrievalQA, ConversationalRetrievalChain
from langchain.document_loaders import TextLoader
from langchain.document_loaders import DirectoryLoader
from langchain.chains.conversation.memory import ConversationBufferMemory
#https://raw.githubusercontent.com/adityaiyer3/DCB_BANK/main/png_icon.png
os.environ["OPENAI_API_KEY"] = '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'
text_loader_kwargs={'autodetect_encoding': True}
loader = DirectoryLoader('./contents/', glob="./*.txt", loader_cls=TextLoader, loader_kwargs=text_loader_kwargs)

documents = loader.load()

text_splitter = RecursiveCharacterTextSplitter(chunk_size=1000, chunk_overlap=200)
texts = text_splitter.split_documents(documents)

####Creating DB #########

persist_directory = 'db'

## here we are using OpenAI embeddings but in future we will swap out to local embeddings
embedding = OpenAIEmbeddings()


#vectordb = Chroma.from_documents(documents=texts, 
#                                embedding=embedding,
#                                persist_directory=persist_directory)


#persiste the db to disk
#vectordb.persist()
#vectordb = None

# Now we can load the persisted database from disk, and use it as normal. 
vectordb = Chroma(persist_directory=persist_directory, 
                  embedding_function=embedding)

retriever = vectordb.as_retriever()
retriever = vectordb.as_retriever(search_kwargs={"k": 2})

########################################################################################################################################
# Chain
#RetrievalQA
#qa_chain = RetrievalQA.from_chain_type(llm=OpenAI(), 

#                                  chain_type="stuff",
#                                  memory = ConversationBufferMemory(memory_key="chat_history",output_key='result',return_messages=True),
#                                  #memory = ConversationSummaryBufferMemory(llm=OpenAI(),output_key='result'),
#                                  verbose=True,
#                                  retriever=retriever, 
#                                  return_source_documents=True)
########################################################################################################################################

memory = ConversationBufferMemory(memory_key="chat_history",return_messages=True)

# create the chain to answer questions 
qa_chain = ConversationalRetrievalChain.from_llm(OpenAI(temperature=0),
                                  retriever,
                                  memory = memory
                                  #memory = ConversationSummaryBufferMemory(llm=OpenAI(),output_key='result'),
                                  #verbose=True,
                                  #return_source_documents=True
                                  )

## Cite sources
def process_llm_response(llm_response): 
    answer = (llm_response['answer'])
    #sources = []
    ##for source in llm_response["source_documents"]:
       # sources.append(source.metadata['source'])
    ans = answer #<br> <br> Sources: <br> {"<br>".join(sources)}
    final_ans = ans.replace("\n", '<br>')
    return final_ans