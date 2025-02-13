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
    //this.configureStatusBar();

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
    StatusBar.setBackgroundColor({ color: '#ffffff' });
    StatusBar.setStyle({ style: Style.Dark });
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
}
