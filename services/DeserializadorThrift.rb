require 'thrift'

# DeserializadorThrift klklhl
class DeserializadorThrift
  def initialize(byte_array, thrift_class)
    @byte_array = byte_array
    @thrift_class = thrift_class
  end

  def deserializar
    transport = Thrift::FramedTransport.new(@byte_array)
    protocol = Thrift::BinaryProtocol.new(transport)

    obj = @thrift_class.new

    obj.read protocol
  end
end
