import { Component, OnInit, ViewChild } from '@angular/core';
import { IonModal } from '@ionic/angular';
import * as moment from 'moment';
import { FinancasService } from 'src/app/shared/services/financas/financas.service';
import { Preferences } from '@capacitor/preferences';
import { PagamentosService } from 'src/app/shared/services/pagamentos/pagamentos.service';
import { Browser } from '@capacitor/browser';
import { AlertService } from 'src/app/shared/services/alert.service';

@Component({
  selector: 'app-payments',
  templateUrl: './payments.component.html',
  styleUrls: ['./payments.component.scss'],
})
export class PaymentsComponent  implements OnInit {

  currentPagamento:any;
  @ViewChild('modalOptions', { static: false }) modalOptions!: IonModal;
  listPagamentosPendentes:any[] = [];
  listPagamentosPagos:any[] = [];
  screen = 'pendentes';
  currentClient: any;
  filterDataVencimento: string = '';
  filterOsAtendimento: string = '';
  filterStatusPagamento: string = '';
  situacoesPagamento = [
    { label: 'Pago', valor: 'Pago' },
    { label: 'Pendente', valor: 'Pendente' },
    { label: 'Vencido', valor: 'Vencido' }
  ];
  @ViewChild('modalFilterPagamentos', { static: false }) modalFilterPagamentos!: IonModal;
  @ViewChild('modalDetails', { static: false }) modalDetails!: IonModal;

  constructor(
    private finacasService: FinancasService,
    private pagamentoService: PagamentosService,
    private alertService: AlertService,

  ) { }

  ngOnInit() {
    this.loadUserData();

  }

  async loadUserData() {
    try {
      const user = await this.getUserSecurely();

      if (user) {
        this.currentClient = user;
        this.getFinancas();
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
  getFinancas(){
    console.log(this.currentClient);
    const query = '?tipo=Entrada&cliente_cpf=' + this.currentClient.cpf;
    this.finacasService.getFinancasByFilter(query).subscribe((data:any) => {
      console.log(data);
      this.listPagamentosPendentes = data.items.filter((pagamento:any) => pagamento.situacao !== 'Pago');
      this.listPagamentosPagos = data.items.filter((pagamento:any) => pagamento.situacao === 'Pago');
    });
  }

  openOptionsModal(pagamento:any){
    console.log(pagamento)
    this.currentPagamento = pagamento;
    this.modalOptions.present();
  }

  capitalizeFirstLetter(text: string): string {
    return text.charAt(0).toUpperCase() + text.slice(1).toLowerCase();
  }

  getDia(data: string): string {
    return moment(data, 'YYYY-MM-DD').format('DD');
  }

  getMesComAno(data: string): string {
    const mesAbreviado = moment(data, 'YYYY-MM-DD').locale('pt-br').format('MMM');
    const ano = moment(data, 'YYYY-MM-DD').format('YYYY');
    return mesAbreviado.charAt(0).toUpperCase() + mesAbreviado.slice(1) + '/' + ano;
  }

  segmentChanged(event: any) {
    this.screen = event.detail.value;
  }

  formatDate(date:string){
    return moment(date).format('DD/MM/YYYY')
  }

  closeModal() {
    const modal = document.querySelector('#filter-modal') as any;
    modal.dismiss();
  }

  applyFilters() {
    console.log('Filtros aplicados:', {
      dataVencimento: this.filterDataVencimento,
      osAtendimento: this.filterOsAtendimento,
      statusPagamento: this.filterStatusPagamento
    });
    this.closeModal();
  }

  openModalDetails(){
    if(this.currentPagamento.atendimento){
      this.modalOptions.dismiss();
      this.modalDetails.present();
    }else{
      this.alertService.presentAlert('Erro ', `Erro ao encontrar atendimento`);
    }
  }

  criaPagamento(){
    const pagamento = {
      value: this.currentPagamento.valor,
      financa: this.currentPagamento.atendimento.ID,
      billingType: "UNDEFINED",
      dueDate: this.currentPagamento.data_vencimento
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
}
