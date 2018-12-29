module HTMLDom
  def self.doc_nodes(docs)
    all_docs = docs.to_a
    docs.each do |doc|
      children_docs = doc.children
      if children_docs.present?
        all_docs += doc_nodes(children_docs)
      end
    end
    return all_docs
  end
end