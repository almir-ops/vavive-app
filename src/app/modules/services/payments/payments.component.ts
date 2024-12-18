import { Component, OnInit, ViewChild } from '@angular/core';
import { IonModal } from '@ionic/angular';
import * as moment from 'moment';

@Component({
  selector: 'app-payments',
  templateUrl: './payments.component.html',
  styleUrls: ['./payments.component.scss'],
})
export class PaymentsComponent  implements OnInit {

  currentPagamento:any;
  @ViewChild('modalOptions', { static: false }) modalOptions!: IonModal;
  listPagamentos:any[] = [];
  constructor() { }

  ngOnInit() {}



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
}
