import { ListServicesComponent } from './modules/services/list-services/list-services.component';
import { CUSTOM_ELEMENTS_SCHEMA, NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { RouteReuseStrategy } from '@angular/router';

import { IonicModule, IonicRouteStrategy } from '@ionic/angular';

import { AppComponent } from './app.component';
import { AppRoutingModule } from './app-routing.module';
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';
import { AuthModule } from './modules/auth/auth.module';
import { SharedModule } from './shared/shared.module';
import { HomeComponent } from './modules/home/home.component';
import { StartComponent } from './modules/start/start.component';
import {MaskitoDirective} from '@maskito/angular';
import { TokenProviderInterceptor } from './core/interceptors/token-provider.interceptor';
import { SelectRegionComponent } from './modules/select-region/select-region.component';
import { IonicStorageModule } from '@ionic/storage-angular';
import { ServicesComponent } from './modules/services/services.component';
import { FormsModule, ReactiveFormsModule } from '@angular/forms';
import { NewServicesComponent } from './modules/services/new-services/new-services.component';
import { ConfirmServicesComponent } from './modules/services/confirm-services/confirm-services.component';
import { LottieComponent, provideLottieOptions } from 'ngx-lottie';
import player from 'lottie-web';
import { LoadingInterceptor } from './core/interceptors/loading.interceptor';
import { PaymentsComponent } from './modules/services/payments/payments.component';

@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    StartComponent,
    SelectRegionComponent,
    ServicesComponent,
    NewServicesComponent,
    ConfirmServicesComponent,
    ListServicesComponent,
    PaymentsComponent
  ],
  imports: [
    BrowserModule,
    IonicModule.forRoot(),
    AppRoutingModule,
    HttpClientModule,
    AuthModule,
    SharedModule,
    MaskitoDirective,
    IonicStorageModule.forRoot(),
    ReactiveFormsModule,
    FormsModule,
    LottieComponent

  ],
  providers: [
    { provide: RouteReuseStrategy, useClass: IonicRouteStrategy },
    {
      provide: HTTP_INTERCEPTORS,
      useClass: TokenProviderInterceptor,
      multi: true,
    },
    provideLottieOptions({
      player: () => player,
    }),
    { provide: HTTP_INTERCEPTORS, useClass: LoadingInterceptor, multi: true },

  ],
  bootstrap: [AppComponent],
  schemas: [CUSTOM_ELEMENTS_SCHEMA]

})
export class AppModule {}
