def init
  @required_files ||= []
  object.children.each do |child|
    if child.type == :module || child.type == :class
      child.format(options)
    end
  end

  object[:required] = true if !object.docstring.empty? || object.meths.any? { |meth| !meth.docstring.empty? }
  @required_files = all_required(object.children) if object.parent.root?

  sections :requires, :index, [:class_description, [T('docstring')], T('methods')]
end

def requires
  return if object.parent.root?
  erb('requires')
end

def all_required(children)
  children.select { |children| children[:required] } + children.select { |child| child.type == :module || child.type == :class
  }.map { |child| all_required(child.children) }
end

def full_path(obj)
  options[:serializer].full_path(obj)
end
