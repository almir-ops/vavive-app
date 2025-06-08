import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { Platform } from '@ionic/angular';
import { register } from 'swiper/element/bundle';
import { Storage } from '@ionic/storage-angular';
import { App } from '@capacitor/app';
import { Capacitor } from '@capacitor/core';
import { environment } from 'src/environments/environment';
import { HttpClient } from '@angular/common/http';
import { SafeArea } from 'capacitor-plugin-safe-area';
import { SplashScreen } from '@capacitor/splash-screen';

register();

@Component({
  selector: 'app-root',
  templateUrl: 'app.component.html',
  styleUrls: ['app.component.scss'],
})
export class AppComponent {
  constructor(
    private platform: Platform,
    private storage: Storage,
    private router: Router,
    private http: HttpClient
  ) {
    this.initializeApp();
    this.checkAppVersion();
    if (this.platform.is('ios')) {
      document.body.classList.add('ios-padding');
    }
  }

  async initializeApp() {

    this.platform.ready().then(() => {
      SplashScreen.hide();
    });
    
    await this.storage.create();
    const apiUrl = await this.storage.get('api_url');
    const endereco = await this.storage.get('endereco');

    if (!apiUrl || !endereco) {
      this.router.navigate(['/select-region']);
    } else {
      this.router.navigate(['/']);
    }

  }

  configureStatusBar() {
    //StatusBar.setBackgroundColor({ color: '#ffffff' });
    //StatusBar.setStyle({ style: Style.Dark });
  }

  checkAppVersion() {
    const platform = Capacitor.getPlatform(); // 'android', 'ios', 'web'
    const currentVersion = environment.appVersion;

    this.http
      .get<{ version: string }>(`${environment.baseUrl}franquias/version`)
      .subscribe((res: any) => {
        const latestVersion = res[0];
        if (currentVersion === latestVersion) {
          return;
        } else {
          this.showUpdateModal(platform);
        }
      });
  }

  isOutdated(current: string, latest: string): boolean {
    const cur = current.split('.').map(Number);
    const lat = latest.split('.').map(Number);

    for (let i = 0; i < Math.max(cur.length, lat.length); i++) {
      if ((cur[i] || 0) < (lat[i] || 0)) return true;
      if ((cur[i] || 0) > (lat[i] || 0)) return false;
    }
    return false;
  }

  async checkForUpdate() {

    const info = await App.getInfo(); 

    const platform = Capacitor.getPlatform(); // 'android', 'ios', 'web'

    const currentVersion = info.version;

    try {
      const response = await fetch('https://matriz.vavive.com.br/versao.json');
      const data = await response.json();

      const latestVersion = data[platform];

      if (this.compararVersao(currentVersion, latestVersion)) {
        this.showUpdateModal(platform);
      }
    } catch (error) {
      console.error('Erro ao verificar versão:', error);
    }
  }

  async showUpdateModal(platform: string) {
    const alert = document.createElement('ion-alert');
    alert.header = 'Atualização disponível';
    alert.message =
      'Uma nova versão do app está disponível. Por favor atualize.';
    alert.backdropDismiss = false; // <== impede fechar tocando fora

    alert.buttons = [
      {
        text: 'Atualizar',
        handler: () => {
          if (platform === 'android') {
            window.open(
              'https://play.google.com/store/apps/details?id=io.ionic.vavive',
              '_system'
            );
          } else if (platform === 'ios') {
            window.open('https://apps.apple.com/app/id6740406088', '_system');
          }
        },
      },
    ];

    document.body.appendChild(alert);
    await alert.present();
  }

  compararVersao(versaoAtual: string, versaoNova: string): boolean {
    return versaoAtual !== versaoNova;
  }
}
