import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';

import { IonicModule } from '@ionic/angular';
import { MenuComponent } from './components/menu/menu.component';
import { ToolbarComponent } from './components/toolbar/toolbar.component';
import { AlertComponent } from './components/alert/alert.component';
import { LoadingComponent } from './components/loading/loading.component';


@NgModule({
  declarations: [
    MenuComponent,
    ToolbarComponent,
    AlertComponent,
    LoadingComponent,
  ],
  imports: [
    CommonModule,
    IonicModule.forRoot(),
  ],
  exports:[
    MenuComponent,
    ToolbarComponent,
    AlertComponent,
    LoadingComponent
  ]
})
export class SharedModule { }
