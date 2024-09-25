import { uEndereco } from "./uEndereco";
import { uFiles } from "./uFiles";
import { uPlanos } from "./uPlanos";
import { uStatusCliente } from "./uStatusCliente";

export interface uCliente {
  ID?: number;

  nome: string;
  cpf: string;
  observacao: string;
  origemCliente: string;
  email: string;
  status: uStatusCliente[];
  saldo: number;
  rating: number;
  telefone: string;
  celular: string;
  enderecos: uEndereco[];
  planos: uPlanos[];
  midias: uFiles[];
  asaas_id: string;
  responsavelNome: string;
  responsavelTelefone: string;
  responsavelEmail: string;
  password: string;
  source: string;
}
