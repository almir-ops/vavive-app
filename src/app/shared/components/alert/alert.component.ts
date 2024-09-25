import { Component, Input, OnInit } from '@angular/core';

@Component({
  selector: 'app-alert',
  templateUrl: './alert.component.html',
  styleUrls: ['./alert.component.scss'],
})
export class AlertComponent {

  @Input() alertButtons = ['Fechar'];
  @Input() header = 'Alerta';
  @Input() message = '';

  showAlert: boolean = false;

  constructor() { }

  presentAlert() {
    this.showAlert = true;
  }

  closeAlert() {
    this.showAlert = false;
  }
}
