require 'rufo'
class DragonDocSerializer < YARD::Serializers::FileSystemSerializer
  attr_reader :docs

  def initialize(opts = {})
    super
    @docs = []
  end

  def serialize(object, data)
    return if data && /\A[[:space:]]*\z/.match?(data)
    data = Rufo.format(data)
    super(object, data)
    # @docs << data
  end

  def full_path(object)
    File.join(basepath, serialized_path(object))
  end

  def serialized_path(object)
    return object if object.is_a?(String)

    if object.is_a?(CodeObjects::ExtraFileObject)
      fspath = ['file.' + object.name + (extension.empty? ? '' : ".#{extension}")]
    else
      objname = object != YARD::Registry.root ? mapped_name(object) : "top-level-namespace"
      objname += '_' + object.scope.to_s[0, 1] if object.is_a?(CodeObjects::MethodObject)
      fspath = [objname + (extension.empty? ? '' : ".#{extension}")]
      if object.namespace && object.namespace.path != ""
        fspath.unshift(*object.namespace.path.split(CodeObjects::NSEP))
      end
    end

    File.join(*fspath.map(&:downcase))
  end

  def mapped_name(object)
    r = "#{underscore object.name}_docs"
  end

  def underscore(camel_cased_word)
    return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)
    word = camel_cased_word.to_s.gsub("::", "/")
    word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
end

YARD::Templates::Template.extra_includes = [YARD::Templates::Helpers::TextHelper]

def init
  options[:extension] = 'rb'
  options[:basepath] = 'lib_docs'
  options[:serializer] = DragonDocSerializer.new(options)

  YARD::Registry.root.children.each do |child|
    if child.type == :module || child.type == :class
      child.format(options)
    end
  end

  # binding.irb
end
