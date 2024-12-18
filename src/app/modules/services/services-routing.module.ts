import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { ServicesComponent } from './services.component';
import { NewServicesComponent } from './new-services/new-services.component';
import { ConfirmServicesComponent } from './confirm-services/confirm-services.component';
import { ListServicesComponent } from './list-services/list-services.component';
import { PaymentsComponent } from './payments/payments.component';

const routes: Routes = [
  {
    path:'',
    component: ServicesComponent,
    children:[
      {
        path:'',
        component: ListServicesComponent,
      },
      {
        path:'new',
        component: NewServicesComponent,
      },
      {
        path:'confirm',
        component: ConfirmServicesComponent,
      },
      {
        path:'pagamentos',
        component: PaymentsComponent,
      }
    ]
  },


];

@NgModule({
  imports: [RouterModule.forChild(routes)],
  exports: [RouterModule]
})
export class ServicesRoutingModule { }
