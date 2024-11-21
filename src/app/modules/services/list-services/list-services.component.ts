import { Component, OnInit, ViewChild } from '@angular/core';
import { AtendimentosService } from 'src/app/shared/services/atendimentos/atendimentos.service';
import { Preferences } from '@capacitor/preferences';
import { Router } from '@angular/router';
import * as moment from 'moment';
import { LoadingComponent } from 'src/app/shared/components/loading/loading.component';
import { IonModal } from '@ionic/angular';
import { PagamentosService } from 'src/app/shared/services/pagamentos/pagamentos.service';
import { Browser } from '@capacitor/browser';
import { AlertService } from 'src/app/shared/services/alert.service';
import { ProfissionalService } from 'src/app/shared/services/profissional/profissional.service';
import { AlertComponent } from 'src/app/shared/components/alert/alert.component';
import { FinancasService } from 'src/app/shared/services/financas/financas.service';
import { RepasseService } from 'src/app/shared/services/repasses/repasse.service';

@Component({
  selector: 'app-list-services',
  templateUrl: './list-services.component.html',
  styleUrls: ['./list-services.component.scss'],
})
export class ListServicesComponent  implements OnInit {

  screnn: string = 'profile';
  currentClient: any;
  currentAtendimento: any;

  listAgendados: any[] = [];
  listHistorico: any[] = [];
  @ViewChild('loadingComponent') loadingComponent!: LoadingComponent;
  @ViewChild('modalOptions', { static: false }) modalOptions!: IonModal;
  @ViewChild('modalCancel', { static: false }) modalCancel!: IonModal;
  @ViewChild('modalDate', { static: false }) modalDate!: IonModal;
  @ViewChild('modalDetails', { static: false }) modalDetails!: IonModal;
  @ViewChild('modalDetailsProfissional', { static: false }) modalDetailsProfissional!: IonModal;
  @ViewChild('modalEvaluation', { static: false }) modalEvaluation!: IonModal;
  @ViewChild('modalStatusCliente', { static: false }) modalStatusCliente!: IonModal;
  @ViewChild('alertComponent') alertComponent!: AlertComponent;

  cancelDescription: string = '';
  minDate!: string;
  rating = 0;
  stars = [1, 2, 3, 4, 5];
  optionListStatusCliente: any;
  selectStatusValue:any;
  constructor(
    private atendimentoService: AtendimentosService,
    private router: Router,
    private pagamentoService: PagamentosService,
    private alertService: AlertService,
    private profissionalService: ProfissionalService,
    private financasService: FinancasService,
    private repasseService: RepasseService

  ) { }

  ngOnInit() {
    this.loadUserData();
    this.setMinDate();

  }

  setMinDate() {
    this.minDate = moment().add(1, 'days').format('YYYY-MM-DD');
  }
  segmentChanged(event: any) {
    this.screnn = event.detail.value;
  }

  async loadUserData() {
    try {
      const user = await this.getUserSecurely();
      console.log(user);

      if (user) {
        this.currentClient = user;
        console.log(this.currentClient);
        this.getAtendimentos();
      } else {
        console.log('Nenhum usuário encontrado.');
      }
    } catch (error) {
      console.error('Erro ao recuperar o usuário:', error);
    }
  }


  async getUserSecurely() {
    try {
      const { value: user } = await Preferences.get({ key: 'user_data' });
      return user ? JSON.parse(user) : null;
    } catch (error) {
      console.error('Erro ao recuperar os dados do usuário:', error);
      return null;
    }
  }

  getAtendimentos() {
    this.atendimentoService.filterAtendimentos('cliente_cpf', this.currentClient.cpf).subscribe({
      next: (res: any) => {
        const hoje = moment(); // Data atual
        this.listAgendados = [];
        this.listHistorico = [];

        res.items.forEach((atendimento: any) => {
          const dataInicio = moment(atendimento.data_inicio, 'YYYY-MM-DD'); // Converte a data_inicio para um objeto moment

          if (atendimento.status_atendimento === 'Cancelado'|| atendimento.status_atendimento === 'Concluido') {
            // Atendimentos cancelados vão para o histórico, independente da data
            this.listHistorico.push(atendimento);
          } else if (dataInicio.isBefore(hoje, 'day') ) {
            // Atendimentos concluídos ou com data no passado também vão para o histórico
            this.listHistorico.push(atendimento);
          } else {
            // Atendimentos futuros e não cancelados/concluídos vão para a lista de agendados
            this.listAgendados.push(atendimento);
          }
        });

        // Ordena os agendados e históricos pela data
        this.listAgendados.sort((a: any, b: any) => moment(a.data_inicio).diff(moment(b.data_inicio)));
        this.listHistorico.sort((a: any, b: any) => moment(a.data_inicio).diff(moment(b.data_inicio)));

        console.log('Atendimentos Agendados:', this.listAgendados);
        console.log('Histórico de Atendimentos:', this.listHistorico);
      },
      error: (err: any) => {
        console.log(err);
      }
    });
  }

  isConfirmarAtendimentoDisponivel(): boolean {
    if (!this.currentAtendimento) {
      return false;
    }

    const dataAtual = moment();
    const dataInicioAtendimento = moment(this.currentAtendimento.data_inicio, 'YYYY-MM-DD');
    const horaDeEntradaAtendimento = moment(this.currentAtendimento.hora_de_entrada, 'HH:mm');

    const dataValida = dataInicioAtendimento.isSameOrBefore(dataAtual, 'day');
    const horaValida = horaDeEntradaAtendimento.isSameOrBefore(dataAtual, 'minute');

    return this.currentAtendimento.status_atendimento !== 'Concluido' && dataValida && horaValida;
  }

  canChangeDate(): boolean {
    if (!this.currentAtendimento) {
      return false;
    }

    const dataAtual = moment();
    const dataInicioAtendimento = moment(this.currentAtendimento.data_inicio, 'YYYY-MM-DD');

    const diferencaDias = dataInicioAtendimento.diff(dataAtual, 'days');

    return this.currentAtendimento.status_atendimento !== 'Cancelado' &&
           this.currentAtendimento.status_atendimento !== 'Concluido' &&
           diferencaDias >= 1;
  }

  canCancelAtendimento(): boolean {
    if (!this.currentAtendimento) {
      return false;
    }

    const dataAtual = moment(); // Data e hora atual
    const dataInicioAtendimento = moment(this.currentAtendimento.data_inicio, 'YYYY-MM-DD');

    // Verifica se a data do atendimento está pelo menos 1 dia antes da data atual
    const diferencaDias = dataInicioAtendimento.diff(dataAtual, 'days');

    // Permite cancelar se o status não for "Cancelado" ou "Realizado" e a diferença de dias for maior ou igual a 1
    return this.currentAtendimento.status_atendimento !== 'Cancelado' &&
           this.currentAtendimento.status_atendimento !== 'Concluido' &&
           diferencaDias >= 1;
  }

  canAvaliacao(): boolean {
    if (!this.currentAtendimento) {
      return false;
    }

    return this.currentAtendimento.status_atendimento !== 'Cancelado' &&
           this.currentAtendimento.status_atendimento === 'Concluido' &&
           this.currentAtendimento.nota === 0;
  }

  navegate(rota:any){
    this.router.navigate([rota]);
  }

  getDia(data: string): string {
    return moment(data, 'YYYY-MM-DD').format('DD');
  }

  capitalizeFirstLetter(text: string): string {
    return text.charAt(0).toUpperCase() + text.slice(1).toLowerCase();
  }

  getMesComAno(data: string): string {
    const mesAbreviado = moment(data, 'YYYY-MM-DD').locale('pt-br').format('MMM');
    const ano = moment(data, 'YYYY-MM-DD').format('YYYY');
    return mesAbreviado.charAt(0).toUpperCase() + mesAbreviado.slice(1) + '/' + ano;
  }

  openOptionsModal(atendimento:any){
    console.log(atendimento)
    this.currentAtendimento = atendimento;
    this.modalOptions.present();
  }

  onWillDismiss() {

  }

  criaPagamento(){
    const pagamento = {
      value: this.currentAtendimento.valor_total,
      atendimento: this.currentAtendimento.ID,
      billingType: "UNDEFINED",
      dueDate: this.currentAtendimento.data_inicio
    }
    this.pagamentoService.criaPagamento(pagamento).subscribe({
      next: async (res: any) => {
        console.log(res);
        await Browser.open({ url: res.item.invoiceUrl });
      },
      error: (err: any) => {
        console.log(err);
        this.alertService.presentAlert('Erro ', `Erro ao gerar cobrança`);

      }
    })
  }

  openModalEvaluation(){

    this.modalOptions.dismiss();
    this.modalEvaluation.present();
  }

  openModalCancelAtendimento(){
    this.modalOptions.dismiss();
    this.modalCancel.present();
  }

  openModalDateAtendimento(){
    this.modalOptions.dismiss();
    this.modalDate.present();
  }

  openModalDetails(){
    this.modalOptions.dismiss();
    this.modalDetails.present();
  }

  openModalDetailsProfissional(){
    if(this.currentAtendimento.profissional.length > 0){
      this.modalOptions.dismiss();
      this.modalDetailsProfissional.present();
    }else{
      this.alertService.presentAlert('Atenção ', `Atendimento sem profissional escalado.`);

    }
  }

  openModalStatusCliente(){
    this.selectStatusValue = this.currentAtendimento.status_cliente;
    this.optionListStatusCliente = [
      {label:'Aguardando',valor:'Aguardando'},
      {label:'Atraso - Avisou',valor:'Atraso - Avisou'},
      {label:'Atraso - Chateado',valor:'Atraso - chateado'},
      {label:'Atraso - Urgente',valor:'Atraso - urgente'},
      {label:'Em atendimento',valor:'Em atendimento'},
      {label:'Produto/equipamento',valor:'Produto/equipamento'},
      //{label:'Prof - duplicada',valor:'Prof - duplicada'},
      {label:'Prof - foto',valor:'Prof - foto'},
      {label:'Prof - função errada',valor:'Prof - função errada'},
      {label:'Prof - sem carteirinha',valor:'Prof - sem carteirinha'},
      {label:'Prof. na porta',valor:'Prof. na porta'},
      {label:'Problema serio - urgente',valor:'Problema serio - urgente'},
      {label:'Sem status',valor:''},
      //{label:'Troca - chateado',valor:'Troca - chateado'},
      //{label:'Troca - prof diferente',valor:'Troca - prof diferente'},
      //{label:'Troca - urgente',valor:'Troca - urgente'},
    ];
    this.modalOptions.dismiss();
    this.modalStatusCliente.present();
  }

  confirmedAtendimento(){
    if(this.currentAtendimento.profissional.length === 0){
      this.alertService.presentAlert('Atenção ', `Atendimento sem profissional, impossivel confirmar.`);
      return
    }else{
      this.currentAtendimento.profissional[0].atendimentos_feitos =+ 1;
      this.currentAtendimento.status_atendimento = 'Concluido';
      this.currentAtendimento.status_profissional = 'Concluido';
      this.updateAtendimento(this.currentAtendimento);
      this.updateProfissional(this.currentAtendimento.profissional[0]);
      this.openModalEvaluation();
      this.criaRepasse(this.currentAtendimento)
    }
  }

  confirmCancel() {
    this.currentAtendimento.status_repase = 'Cancelado'
    this.currentAtendimento.status_atendimento = 'Cancelado'
    this.currentAtendimento.motivo_cancelamento = 'Cancelado pelo cliente'
    this.currentAtendimento.descricao_cancelamento = this.cancelDescription
    this.currentAtendimento.status_profissional = 'Cancelado'
    // Lógica para cancelar o atendimento
    if (this.cancelDescription.length >= 5) {
      // Aqui você pode enviar o motivo do cancelamento para o backend ou processar a ação de cancelamento
      console.log('Atendimento cancelado com o motivo:', this.cancelDescription);
      this.updateAtendimento(this.currentAtendimento)
      // Fechar o modal após a confirmação
      this.modalCancel.dismiss();
    }
  }

  updateAtendimento(atendimento:any){
    this.atendimentoService.putAttendence(atendimento).subscribe({
      next:(res:any)=>{
        console.log(res);
        this.modalCancel.dismiss();
        //this.getAtendimentos();
      },
      error:(err:any)=>{
        console.log(err);
      }
    })
  }

  updateDatasSelecionadas(dataAntiga: string, novaData: string) {
    // Verifica se datas_selecionadas é uma string e a converte em um array
    let datasSelecionadasArray: string[];

    if (typeof this.currentAtendimento.datas_selecionadas === 'string') {
      // Se for uma string, converte-a para um array
      datasSelecionadasArray = JSON.parse(this.currentAtendimento.datas_selecionadas);
    } else {
      // Se já for um array, apenas atribui
      datasSelecionadasArray = this.currentAtendimento.datas_selecionadas;
    }

    const diaDaSemana = moment(novaData).isoWeekday(); // Obtém o número do dia da semana (1=segunda, 2=terça, etc.)

    // Mapeia o array e substitui a data correspondente
    const updatedDatasSelecionadasArray = datasSelecionadasArray.map((data: string) => {
      // Verifica se a data atual (sem o dia da semana) é igual à data antiga
      const dataSemDia = data.split(' (')[0]; // Remove a parte do dia da semana

      if (dataSemDia === dataAntiga) {
        // Substitui a data antiga pela nova
        return novaData + ` (${diaDaSemana})`; // Adiciona o novo dia da semana
      }

      return data; // Retorna a data sem alteração
    });

    // Converte o array de volta para string no formato desejado
    this.currentAtendimento.datas_selecionadas = JSON.stringify(updatedDatasSelecionadasArray);
  }

  onDateSelected(event: any) {
    this.updateDatasSelecionadas(this.currentAtendimento.data_inicio,event.detail.value);
    this.currentAtendimento.data_inicio = event.detail.value;
    console.log(this.currentAtendimento);
    this.updateAtendimento(this.currentAtendimento);
    this.modalDate.dismiss();
  }

  formatDate(date:string){
    return moment(date).format('DD/MM/YYYY')
  }

    // Função para definir a nota
    setRating(starIndex: number) {
      this.rating = starIndex;
      console.log(this.rating);

    }

    // Função para fechar o modal
    closeModal() {
      // Fechar o modal logicamente (pode ser implementado com seu modal controlador)
      console.log('Modal fechado');
    }

    // Função para enviar a avaliação
    submitReview() {
      console.log(this.currentAtendimento);

      // Obter o valor do textarea e a nota para envio
      const reviewText = (document.getElementById('evaluation-textarea') as HTMLTextAreaElement).value;
      console.log('Avaliação: ', reviewText, 'Nota: ', this.rating);

      this.currentAtendimento.nota = this.rating;
      this.currentAtendimento.avaliacao = reviewText;

      this.updateAtendimento(this.currentAtendimento);
      this.currentAtendimento.profissional[0].atendimentos_feitos =+ 1;
      const valorMedia = this.calcularMediaNota(this.currentAtendimento.profissional[0].atendimentos_feitos, this.currentAtendimento.nota)
      console.log(valorMedia);
      this.currentAtendimento.profissional[0].rating = valorMedia;
      this.updateProfissional(this.currentAtendimento.profissional[0]);
      this.modalEvaluation.dismiss();
    }

    submitStatus(){
      this.currentAtendimento.status_cliente = this.selectStatusValue;
      this.updateAtendimento(this.currentAtendimento);
      this.modalStatusCliente.dismiss();
    }

    criaRepasse(atendimento: any) {
      const atendimentoID = atendimento.ID.toString();

      // Use async/await to get the repasse value
      const getRepasseValue = async () => {
        let valorRepasse: number | undefined = await this.buscaValorRepasse(atendimento.duracao, atendimento.profissional[0].grupo_repasse);

        console.log('Valor Repasse:', valorRepasse);

        if (valorRepasse === 0 || valorRepasse === undefined || valorRepasse === null) {
          valorRepasse = this.profissionalService.calcularValorRepasses(atendimento.duracao, atendimento.profissional[0].grupo_repasse);
          console.log('Valor Repasse calculado:', valorRepasse);
        }

        return valorRepasse;
      };

      // Function to create the 'financa' object
      const criarFinanca = (valorRepasse: number) => {
        if (atendimento.repasse_personalizado) {
          return {
            nome: atendimento.profissional[0].nome,
            tipo_financa: "Repasses",
            observacao: atendimento.repasse_observacao,
            valor: atendimento.repasse_valor,
            situacao: "Pendente",
            forma_de_pagamento: atendimento.repasse_tipo_pagamento,
            atendimento: { ID: atendimento.ID },
            profissional: { ID: atendimento.profissional[0].ID },
            estado: atendimento.endereco.estado,
            tipo: "Repasse",
            target_invoice: "profissional",
            data_vencimento: atendimento.data_inicio
          };
        } else {
          return {
            nome: atendimento.profissional[0].nome,
            tipo_financa: "Repasses",
            observacao: "refente ao atendimento com OS: " + atendimento.ID,
            valor: valorRepasse ?? 0, // Default to 0 if valorRepasse is still undefined
            situacao: "Pendente",
            forma_de_pagamento: atendimento.forma_de_pagamento,
            atendimento: { ID: atendimento.ID },
            profissional: { ID: atendimento.profissional[0].ID },
            estado: atendimento.endereco.estado,
            tipo: "Repasse",
            target_invoice: "profissional",
            data_vencimento: atendimento.data_inicio
          };
        }
      };

      // Use async/await for the whole method
      const processarRepasse = async () => {
        try {
          const valorRepasse = await getRepasseValue();
          console.log('Final Valor Repasse:', valorRepasse);

          // Executa a verificação de financas antes de criar o repasse
          this.financasService.getRPagamentosByDatesAndFilter(atendimento.data_inicio, atendimento.data_inicio, '&tipo=Repasse&atendimento_id=' + atendimento.ID)
            .subscribe({
              next: (res: any) => {
                // Apenas cria o repasse se não houver resultado na busca de financa
                console.log(res);
                if (res.items.length === 0) {
                  const financa = criarFinanca(valorRepasse);
                  // Faz a requisição para criar a financa
                  console.log(financa);

                  this.financasService.postFinancas([financa]).subscribe({
                    next: (res: any) => {
                      console.log('Repasse criado:', res);
                    },
                    error: (err: any) => {
                      console.error('Erro ao criar repasse:', err);
                    }
                  });
                } else {
                  console.log('Repasse já existe, não será criado.');
                }
              },
              error: (err: any) => {
                console.error('Erro ao buscar financas:', err);
              }
            });
        } catch (error) {
          console.error('Erro ao processar o repasse:', error);
        }
      };

      processarRepasse();
    }

    buscaValorRepasse(duracao: any, grupo_repasse: any): Promise<number | undefined> {
      return new Promise((resolve, reject) => {
        this.repasseService.getRepassesByFilters('?duracao=' + duracao + '&grupo_repasse=' + grupo_repasse).subscribe({
          next: (res: any) => {
            if (res.items && res.items.length > 0 && res.items[0].valor != null) {
              console.log('Valor encontrado ', res.items[0].valor);
              resolve(res.items[0].valor);
            } else {
              console.log('Nenhum valor encontrado. Usando valor padrão ou undefined.');
              resolve(undefined); // ou um valor padrão, como resolve(0)
            }
          },
          error: (err: any) => {
            console.error(err);
            reject(err);
          }
        });
      });
    }

    updateProfissional(profissional:any){
      this.profissionalService.putProfissional(profissional)
      .subscribe(
        response => {
          console.log(response);
        },
        error => {
          //this.alertService.presentAlert('Erro ', `Erro ao gerar cobrança`);

        }
      );
    }

    calcularMediaNota( quantidadeAtendimentos: number,somaNotas: number): number {
      if (quantidadeAtendimentos === 0) {
        // Evita divisão por zero
        return 0;
      }

      const media = somaNotas / quantidadeAtendimentos;
      return parseFloat(media.toFixed(2)); // Arredonda para 2 casas decimais
    }

}
