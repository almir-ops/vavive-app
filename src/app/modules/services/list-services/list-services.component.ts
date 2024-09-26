import { Component, OnInit, ViewChild } from '@angular/core';
import { AtendimentosService } from 'src/app/shared/services/atendimentos/atendimentos.service';
import { Preferences } from '@capacitor/preferences';
import { Router } from '@angular/router';
import * as moment from 'moment';
import { LoadingComponent } from 'src/app/shared/components/loading/loading.component';
import { IonModal } from '@ionic/angular';
import { PagamentosService } from 'src/app/shared/services/pagamentos/pagamentos.service';
import { Browser } from '@capacitor/browser';

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

  cancelDescription: string = '';
  minDate!: string;

  constructor(
    private atendimentoService: AtendimentosService,
    private router: Router,
    private pagamentoService: PagamentosService
  ) { }

  ngOnInit() {
    this.loadUserData();
    this.setMinDate()
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
    this.showLoading();
    this.atendimentoService.filterAtendimentos('cliente_cpf', this.currentClient.cpf).subscribe({
      next: (res: any) => {
        const hoje = moment(); // Data atual
        this.listAgendados = [];
        this.listHistorico = [];

        res.items.forEach((atendimento: any) => {
          const dataInicio = moment(atendimento.data_inicio, 'YYYY-MM-DD'); // Converte a data_inicio para um objeto moment

          if (atendimento.status_atendimento === 'Cancelado'|| atendimento.status_atendimento === 'Realizado') {
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
        this.hideLoading();
      },
      error: (err: any) => {
        console.log(err);
        this.hideLoading();
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

    return this.currentAtendimento.status_atendimento !== 'Realizado' && dataValida && horaValida;
  }

  canChangeDate(): boolean {
    if (!this.currentAtendimento) {
      return false;
    }

    const dataAtual = moment();
    const dataInicioAtendimento = moment(this.currentAtendimento.data_inicio, 'YYYY-MM-DD');

    const diferencaDias = dataInicioAtendimento.diff(dataAtual, 'days');

    return this.currentAtendimento.status_atendimento !== 'Cancelado' &&
           this.currentAtendimento.status_atendimento !== 'Realizado' &&
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
           this.currentAtendimento.status_atendimento !== 'Realizado' &&
           diferencaDias >= 1;
  }

  navegate(rota:any){
    this.router.navigate([rota]);
  }

  showLoading() {
    this.loadingComponent.createLoading();
  }

  hideLoading() {
    this.loadingComponent.dismissLoading();
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
    this.showLoading();
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
        this.hideLoading();
      },
      error: (err: any) => {
        console.log(err);
      }
    })
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

  confirmedAtendimento(){
    this.currentAtendimento.status_atendimento = 'Realizado'
    this.currentAtendimento.status_profissional = 'Concluido'
    this.updateAtendimento(this.currentAtendimento)
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
        this.getAtendimentos();
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
}
