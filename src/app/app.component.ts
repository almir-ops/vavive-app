import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { Platform } from '@ionic/angular';
import { register } from 'swiper/element/bundle';
import { Storage } from '@ionic/storage-angular';
import { StatusBar, Style } from '@capacitor/status-bar';
import { PushNotifications, Token, PermissionStatus } from '@capacitor/push-notifications';
import { ClientesService } from './shared/services/clientes/clientes.service';
import { Preferences } from '@capacitor/preferences';
import { ScreenOrientation } from '@capacitor/screen-orientation';
import { App } from '@capacitor/app';
import { Capacitor } from '@capacitor/core';

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
    private clienteService: ClientesService
  ) {
    this.initializeApp();
    this.disableDarkMode();
    this.configureStatusBar();
    this.checkForUpdate();
  }



  disableDarkMode() {
    document.body.classList.add('light');
    document.body.classList.remove('dark');
  }

  async initializeApp() {
    //await ScreenOrientation.lock({ orientation: 'portrait' });

    await this.platform.ready();
    await this.storage.create();
    const apiUrl = await this.storage.get('api_url');
    const frontUrl = await this.storage.get('front_url');
    const endereco = await this.storage.get('endereco');
    console.log(apiUrl);
    console.log(endereco);

    if (!apiUrl || !endereco) {
      this.router.navigate(['/select-region']);
    } else {
      this.router.navigate(['/']);
    }

    //this.checkPushNotificationPermission();
  }

  configureStatusBar() {
    //StatusBar.setBackgroundColor({ color: '#ffffff' });
    //StatusBar.setStyle({ style: Style.Dark });
  }

  async checkPushNotificationPermission() {
    // Verificar status da permissão
    const permissionStatus: PermissionStatus = await PushNotifications.checkPermissions();

    if (permissionStatus.receive === 'granted') {
      // Já tem permissão, registra o dispositivo
      this.registerForPushNotifications();
    } else {
      // Solicitar permissão ao usuário
      const result = await PushNotifications.requestPermissions();
      if (result.receive === 'granted') {
        this.registerForPushNotifications();
      } else {
        console.log('Permissão para notificações push negada.');
      }
    }
  }

  registerForPushNotifications() {
    PushNotifications.register();

    // Evento disparado quando o token é gerado
    PushNotifications.addListener('registration', (token: Token) => {
      console.log('Token de notificação gerado:', token.value);
      Preferences.set({
        key: 'token_notification',
        value: JSON.stringify(token.value)
      })
    });

    // Evento disparado se o registro falhar
    PushNotifications.addListener('registrationError', (error) => {
      console.error('Erro no registro de notificações push:', error);
    });
  }

  async checkForUpdate() {
    console.log('checkForUpdate');

    const info = await App.getInfo(); // Pega nome, id, versão etc.
    console.log('checkForUpdate');

    const platform = Capacitor.getPlatform(); // 'android', 'ios', 'web'
        console.log('checkForUpdate');

    const currentVersion = info.version;

    console.log('Plataforma:', platform);
    console.log('Versão atual do app:', currentVersion);

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
    alert.message = 'Uma nova versão do app está disponível. Deseja atualizar agora?';
    alert.buttons = [
      {
        text: 'Cancelar',
        role: 'cancel'
      },
      {
        text: 'Atualizar',
        handler: () => {
          if (platform === 'android') {
            window.open('https://play.google.com/store/apps/details?id=io.ionic.vavive', '_system');
          } else if (platform === 'ios') {
            window.open('https://apps.apple.com/app/id6740406088', '_system');
          }
        }
      }
    ];
    document.body.appendChild(alert);
    await alert.present();
  }



  compararVersao(versaoAtual: string, versaoNova: string): boolean {
    return versaoAtual !== versaoNova;
  }
}
