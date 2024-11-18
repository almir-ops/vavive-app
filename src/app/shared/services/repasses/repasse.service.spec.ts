import { TestBed } from '@angular/core/testing';

import { RepasseService } from './repasse.service';

describe('RepasseService', () => {
  let service: RepasseService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(RepasseService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
