require 'thrift'

# SerializadorThrift klklhl
class SerializadorThrift
  def initialize(thrift_obj)
    @thrift_obj = thrift_obj
  end

  def serializar
    serializer = Thrift::Serializer.new

    serializer.serialize(@thrift_obj)
  end
end
