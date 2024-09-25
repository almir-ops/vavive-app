import { Injectable } from '@angular/core';
import { AlertController } from '@ionic/angular';

@Injectable({
  providedIn: 'root'
})
export class AlertService {

  constructor(private alertController: AlertController) {}

  async presentAlert(header: string, message: string, okCallback?: () => void) {
    const alert = await this.alertController.create({
      header,
      message,
      buttons: [
        {
          text: 'OK',
          cssClass: 'alert-button-confirm',
          handler: () => {
            if (okCallback) {
              okCallback(); // Executa o método quando o botão é clicado
            }
          }
        }
      ]
    });

    await alert.present();
  }
}
