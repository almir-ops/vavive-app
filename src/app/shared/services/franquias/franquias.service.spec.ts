import { TestBed } from '@angular/core/testing';

import { FranquiasService } from './franquias.service';

describe('FranquiasService', () => {
  let service: FranquiasService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(FranquiasService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
