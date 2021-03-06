require 'commonmarker'

# parse the files specified on the command line
doc = CommonMarker::Node.parse_file(ARGF)

# Walk tree and print out URLs for links
doc.walk do |node|
  if node.type == :link
    printf("URL = %s\n", node.url)
  end
end

# Capitalize all regular text in headers
doc.walk do |node|
  if node.type == :header
    node.walk do |subnode|
      if subnode.type == :text
        subnode.string_content = subnode.string_content.upcase
      end
    end
  end
end

# Transform links to regular text
doc.walk do |node|
  if node.type == :link
    node.each_child do |child|
      node.insert_before(child)
    end
    node.delete
  end
end

# Render the transformed document to a string
print(doc.to_html)

# Create a custom renderer.
class MyHtmlRenderer < CommonMarker::HtmlRenderer
  def initialize
    super
    @headerid = 1
  end
  def header(node)
    block do
      self.out("<h", node.header_level, " id=\"", @headerid, "\">",
               :children, "</h", node.header_level, ">")
      @headerid += 1
    end
  end
end

# this renderer prints directly to STDOUT, instead
# of returning a string
myrenderer = MyHtmlRenderer.new
print(myrenderer.render(doc))

# Print any warnings to STDERR
myrenderer.warnings.each do |w|
  STDERR.write(w)
  STDERR.write("\n")
end

# free allocated memory when you're done
doc.free
