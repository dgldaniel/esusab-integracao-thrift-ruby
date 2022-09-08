require 'thrift'

require_relative './models/dado_transporte/dado_transporte_types'
require_relative './models/ficha_procedimentos/ficha_atendimento_procedimento_types'

dir_out = './esus/2bfe3982-abb5-4ae0-9253-9df280e1f245.esus'

dado_transporte_instancia = Br::Gov::Saude::Esusab::Dadotransp::DadoTransporteThrift.new
ficha_instancia = Br::Gov::Saude::Esusab::Ras::Atendprocedimentos::FichaProcedimentoMasterThrift.new

thrift_data = File.read dir_out

deserializer = Thrift::Deserializer.new

dado_transporte_deserializado = deserializer.deserialize dado_transporte_instancia, thrift_data

ficha_serializada = dado_transporte_deserializado.dadoSerializado

ficha_deserializada = deserializer.deserialize ficha_instancia, ficha_serializada

puts ficha_deserializada.inspect
