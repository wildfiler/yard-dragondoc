include T('default/docstring/text')

def init
  return if object.docstring.blank? && object.tags.blank?
  sections :index, T('tags')
end
