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
  cancelDescription: string = '';
  constructor(
    private atendimentoService: AtendimentosService,
    private router: Router,
    private pagamentoService: PagamentosService
  ) { }

  ngOnInit() {
    this.loadUserData();

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
        const hoje = moment(); // Obtém a data atual
        this.listAgendados = []; // Inicializa a lista de agendados
        this.listHistorico = []; // Inicializa a lista de histórico

        // Percorre os atendimentos e separa em duas listas
        res.items.forEach((atendimento: any) => {
          const dataInicio = moment(atendimento.data_inicio, 'YYYY-MM-DD'); // Converte a data_inicio para um objeto moment

          if (dataInicio.isSameOrAfter(hoje, 'day') && atendimento.status_atendimento !== 'Cancelado') {
            // Se a data do atendimento for hoje ou no futuro e não for cancelado, adiciona à lista de agendados
            this.listAgendados.push(atendimento);
          } else {
            // Se a data do atendimento já passou ou estiver cancelado, adiciona à lista de histórico
            this.listHistorico.push(atendimento);
          }
        });

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

  OpenModalCancelAtendimento(){
    this.modalOptions.dismiss();
    this.modalCancel.present();
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

  formatDate(date:string){
    return moment(date).format('DD/MM/YYYY')
  }
}
