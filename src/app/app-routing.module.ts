import { AuthRoutingModule } from './modules/auth/auth-routing.module';
import { NgModule } from '@angular/core';
import { PreloadAllModules, RouterModule, Routes } from '@angular/router';
import { HomeComponent } from './modules/home/home.component';
import { AuthenticatedGuard } from './core/guards/authenticated.guard';
import { StartComponent } from './modules/start/start.component';
import { AccountComponent } from './modules/auth/account/account.component';
import { ServicesComponent } from './modules/services/services.component';
import { SelectRegionComponent } from './modules/select-region/select-region.component';
import { ConfirmServicesComponent } from './modules/services/confirm-services/confirm-services.component';

const routes: Routes = [
  {
    path: '',
    component: HomeComponent,
    children: [
      {
        path: '',
        pathMatch: 'full',
        redirectTo: 'start',
      },
      {
        path: 'start',
        component: StartComponent
       },
      {
        path: 'services',
        loadChildren: () => import('./modules/services/services-routing.module').then(m => m.ServicesRoutingModule),
        canActivate: [AuthenticatedGuard]
      },
      {
        path: 'account',
        loadChildren: () => import('./modules/auth/auth-routing.module').then(m => m.AuthRoutingModule)
      }
    ],
  },
  {
    path: 'login',
    loadChildren: () =>
    import('./modules/auth/auth.module').then((m) => m.AuthModule
    ),
  },
  {
    path: 'select-region',
    component: SelectRegionComponent
  },
];

@NgModule({
  imports: [
    RouterModule.forRoot(routes, { preloadingStrategy: PreloadAllModules })
  ],
  exports: [RouterModule]
})
export class AppRoutingModule {}
