require 'securerandom'

require_relative './models/ficha_procedimentos/ficha_atendimento_procedimento_types'
require_relative './models/dado_transporte/dado_transporte_types'
require_relative './models/common_types'

require_relative './services/SerializadorThrift'

EXTENSAO_EXPORT = '.esus'
TIPO_DADO_SERIALIZADO_FICHA_PROCEDIMENTO = 7

def get_dado_transporte(ficha)
  dado_transporte_thrift = Br::Gov::Saude::Esusab::Dadotransp::DadoTransporteThrift.new

  dado_transporte_thrift.uuidDadoSerializado = ficha.uuidFicha
  dado_transporte_thrift.cnesDadoSerializado = ficha.headerTransport.cnes
  dado_transporte_thrift.codIbge = ficha.headerTransport.codigoIbgeMunicipio
  dado_transporte_thrift.ineDadoSerializado = ficha.headerTransport.ine

  originadora = Br::Gov::Saude::Esusab::Dadotransp::DadoInstalacaoThrift.new

  originadora.contraChave = '123456'
  originadora.uuidInstalacao = 'UUIDUNICO111'
  originadora.cpfOuCnpj = '11111111111'
  originadora.nomeOuRazaoSocial = 'Nome ou Razao Social Originadora'
  originadora.fone = '999999999'
  originadora.email = 'a@b.com'

  dado_transporte_thrift.originadora = originadora

  remetente = Br::Gov::Saude::Esusab::Dadotransp::DadoInstalacaoThrift.new

  remetente.contraChave = '789010'
  remetente.uuidInstalacao = 'UUIDUNICO222'
  remetente.cpfOuCnpj = '11111111111'
  remetente.nomeOuRazaoSocial = 'Nome ou Razao Social Remetente'
  remetente.fone = '98888888'
  remetente.email = 'b@a.com'

  dado_transporte_thrift.remetente = originadora

  dado_transporte_thrift.numLote = 1

  dado_transporte_thrift
end

def get_header
  header_thrift = Br::Gov::Saude::Esusab::Ras::Common::UnicaLotacaoHeaderThrift.new

  header_thrift.profissionalCNS = '898001160660761'
  header_thrift.cboCodigo_2002 = '223212'
  header_thrift.cnes = '7381123'
  header_thrift.ine = '0000406465'
  header_thrift.dataAtendimento = Time.now.to_i
  header_thrift.codigoIbgeMunicipio = '4205407'

  header_thrift
end

def get_procedimentos
  procedimentos_list = []

  procedimentos_list.push('ABPG019'); # SUTURA SIMPLES;
  procedimentos_list.push('ABEX004'); # ELETROCARDIOGRAMA;

  procedimentos_list
end

def get_atendimentos
  lista_procedimentos_atendimento = []

  2.times do
    atendimento_procedimento_thrift = Br::Gov::Saude::Esusab::Ras::Atendprocedimentos::FichaProcedimentoChildThrift.new

    atendimento_procedimento_thrift.numProntuario = '43143'
    atendimento_procedimento_thrift.dtNascimento = Time.now.to_i
    atendimento_procedimento_thrift.sexo = 1
    atendimento_procedimento_thrift.localAtendimento = 1
    atendimento_procedimento_thrift.turno = 1
    atendimento_procedimento_thrift.procedimentos = get_procedimentos
    atendimento_procedimento_thrift.procedimentos = get_procedimentos
    atendimento_procedimento_thrift.cpfCidadao = '80487483391'

    lista_procedimentos_atendimento.push(atendimento_procedimento_thrift)
  end

  lista_procedimentos_atendimento
end

def get_ficha
  thrift_procedimentos = Br::Gov::Saude::Esusab::Ras::Atendprocedimentos::FichaProcedimentoMasterThrift.new
  thrift_procedimentos.uuidFicha = SecureRandom.uuid
  thrift_procedimentos.tpCdsOrigem = 3
  thrift_procedimentos.headerTransport = get_header
  thrift_procedimentos.atendProcedimentos = get_atendimentos
  thrift_procedimentos.numTotalAfericaoPa = 1
  thrift_procedimentos.numTotalGlicemiaCapilar = 1
  thrift_procedimentos.numTotalAfericaoTemperatura = 1
  thrift_procedimentos.numTotalMedicaoAltura = 1
  thrift_procedimentos.numTotalCurativoSimples = 1
  thrift_procedimentos.numTotalMedicaoPeso = 1
  thrift_procedimentos.numTotalColetaMaterialParaExameLaboratorial = 1

  thrift_procedimentos
end

def main
  # Passo 1: Popular a ficha
  thrift_ficha_procedimento = get_ficha

  # Passo 2: Popular o DadoTransporte usando os dados da ficha e do software que está enviando.
  dado_transporte_thrift = get_dado_transporte(thrift_ficha_procedimento)

  # Passo 3: Serializar a ficha utilizando o TBinaryProtocol da biblioteca thrift.
  serializador_ficha = SerializadorThrift.new thrift_ficha_procedimento
  ficha_serializada = serializador_ficha.serializar

  # Passo 4: Adicionar a ficha serializada e seu tipo no DadoTransporte.
  dado_transporte_thrift.tipoDadoSerializado = TIPO_DADO_SERIALIZADO_FICHA_PROCEDIMENTO

  dado_transporte_thrift.dadoSerializado = ficha_serializada

  # Não esquecer de informar a versão da ficha a ser exportada (não é a versão do e-SUS AB)
  versao_thrift = Br::Gov::Saude::Esusab::Dadotransp::VersaoThrift.new

  versao_thrift.major = 3
  versao_thrift.minor = 2
  versao_thrift.revision = 3

  dado_transporte_thrift.versao = versao_thrift

  dado_transporte_serializador = SerializadorThrift.new dado_transporte_thrift
  dado_transporte_serializado = dado_transporte_serializador.serializar

  dir_out = "esus/#{dado_transporte_thrift.uuidDadoSerializado}#{EXTENSAO_EXPORT}"

  File.write dir_out, dado_transporte_serializado
end

main
