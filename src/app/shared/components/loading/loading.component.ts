import { Component, Input } from '@angular/core';
import { LoadingController, LoadingOptions } from '@ionic/angular';

@Component({
  selector: 'app-loading',
  templateUrl: './loading.component.html',
  styleUrls: ['./loading.component.scss'],
})
export class LoadingComponent {
  @Input() messageLoading = 'Carregando';
  private loading!: HTMLIonLoadingElement;

  constructor(private loadingController: LoadingController) {}

  public async createLoading(): Promise<void> {
    if (this.loading) {
      await this.loading.dismiss();
    }

    const loadingOptions: LoadingOptions = {
      animated: true,
      backdropDismiss: false,
      showBackdrop: true,
      spinner: 'bubbles',
      message: this.messageLoading,
      cssClass: 'custom-spinner'
    };

    this.loading = await this.loadingController.create(loadingOptions);
    await this.loading.present();
  }

  public async dismissLoading(): Promise<void> {
    setTimeout(() => {
      this.loading.dismiss();
      if (this.loading) {
          this.loading.dismiss();
      }
    }, 100);
  }
}
