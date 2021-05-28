require "xml"

module XMLReader
  include Loggable

  abstract def parse_document(node : XML::Node, file : File)

  def self.parse_file(path : String, & : XML::Node, File ->) : Nil
    File.open(path) { |file| parse_file(file) { |doc| yield doc, file } }
  end

  def self.parse_file(file : File, & : XML::Node ->) : Nil
    yield XML.parse(file)
  end

  private def parse_datapack_file(path : String) : Nil
    path = "#{Config.datapack_root}/#{path}"

    File.open(path) do |file|
      doc = XML.parse(file)
      parse_document(doc, file)
    end
  end

  private def parse_datapack_directory(path : String) : Nil
    parse_datapack_directory(path, false)
  end

  private def parse_datapack_directory(path : String, recursive : Bool) : Nil
    if recursive
      path = "#{Config.datapack_root}/#{path}/**/*.xml"
    else
      path = "#{Config.datapack_root}/#{path}/*.xml"
    end

    Dir.glob(path) do |file_path|
      XMLReader.parse_file(file_path) { |doc, file| parse_document(doc, file) }
    end
  end

  private def get_first_child(node : XML::Node) : XML::Node
    node.children.first
  end

  private def get_first_element_child(node : XML::Node) : XML::Node?
    node.first_element_child
  end

  private def get_next_element(node : XML::Node) : XML::Node?
    node.next_element
  end

  private def find_element(node : XML::Node, name : String, & : XML::Node ->) : Nil
    each_element(node) { |e, e_name| yield e  if e_name.casecmp?(name) }
  end

  private def each_element(node : XML::Node, & : XML::Node, String ->) : Nil
    node.children.each { |c| yield c, c.name if c.element? }
  end

  private def get_children(node : XML::Node) : Enumerable(XML::Node)
    node.children
  end

  private def each_attribute(node : XML::Node, & : String, String ->) : Nil
    node.attributes.each { |a| yield a.name, a.content }
  end

  private def get_attributes(node : XML::Node) : StatsSet
    attributes = node.attributes
    ret = StatsSet.new(initial_capacity: attributes.size)
    attributes.each { |a| ret[a.name] = a.text }
    ret
  end

  private def get_content(node : XML::Node) : String
    node.content
  end

  private def get_node_name(node : XML::Node) : String
    node.name
  end

  private def parse_string(node : XML::Node, key : String) : String
    node[key]
  end

  private def parse_string(node : XML::Node, key : String, default : T) : String | T forall T
    node[key]? || default
  end

  private def parse_byte(node : XML::Node, key : String) : Int8
    node[key].to_i8
  end

  private def parse_byte(node : XML::Node, key : String, default : T) : Int8 | T forall T
    if val = node[key]?
      return val.to_i8
    end

    default
  end

  private def parse_short(node : XML::Node, key : String) : Int16
    node[key].to_i16
  end

  private def parse_short(node : XML::Node, key : String, default : T) : Int16 | T forall T
    if val = node[key]?
      return val.to_i16
    end

    default
  end

  private def parse_int(node : XML::Node, key : String) : Int32
    node[key].to_i32
  end

  private def parse_int(node : XML::Node, key : String, default : T) : Int32 | T forall T
    if val = node[key]?
      return val.to_i32
    end

    default
  end

  private def parse_long(node : XML::Node, key : String) : Int64
    node[key].to_i64
  end

  private def parse_long(node : XML::Node, key : String, default : T) : Int64 | T forall T
    if val = node[key]?
      return val.to_i64
    end

    default
  end

  private def parse_float(node : XML::Node, key : String) : Float32
    node[key].to_f32
  end

  private def parse_float(node : XML::Node, key : String, default : T) : Float32 | T forall T
    if val = node[key]?
      return val.to_f32
    end

    default
  end

  private def parse_double(node : XML::Node, key : String) : Float64
    node[key].to_f64
  end

  private def parse_double(node : XML::Node, key : String, default : T) : Float64 | T forall T
    if val = node[key]?
      return val.to_f64
    end

    default
  end

  private def parse_bool(node : XML::Node, key : String) : Bool
    node[key].to_b
  end

  private def parse_bool(node : XML::Node, key : String, default : T) : Bool | T forall T
    if val = node[key]?
      return val.to_b
    end

    default
  end

  private def parse_enum(node : XML::Node, key : String, enum_type : E.class) : E forall E
    enum_type.parse(node[key])
  end

  private def parse_enum(node : XML::Node, key : String, enum_type : E.class, default : T) : E | T forall E, T
    if val = node[key]?
      return enum_type.parse(val)
    end

    default
  end
end
