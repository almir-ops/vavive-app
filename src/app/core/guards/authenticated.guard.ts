import { Injectable } from '@angular/core';
import { ActivatedRouteSnapshot, CanActivate, Route, Router, RouterStateSnapshot, UrlSegment, UrlTree } from '@angular/router';
import { Observable } from 'rxjs';
import { AuthService } from 'src/app/modules/auth/auth.service';

@Injectable({
  providedIn: 'root'
})
export class AuthenticatedGuard implements CanActivate {

constructor(private service: AuthService) {}

  canActivate(
    next: ActivatedRouteSnapshot,
    state: RouterStateSnapshot
  ): boolean {
    if (
      next.routeConfig !== undefined &&
      next.routeConfig?.path !== undefined
    ) {
      return this.checkAutenticated(next.routeConfig.path);
    }

    return false;
  }

  canLoad(route: Route, segments: UrlSegment[]): boolean {
    if (route.path !== undefined) {
      return this.checkAutenticated(route.path);
    }
    return false;
  }

  checkAutenticated(path: string): boolean {
    const logged = this.service.isLoggedIn();

    if (!logged) {

      this.service.handleLoggin();
    }

    return logged;
  }
}
