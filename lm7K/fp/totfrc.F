      subroutine totfrc(nbas,ssite,slat,leks,fes1,fes2,dfhf,f)
C- Add together and print contributions to force
C ----------------------------------------------------------------------
Ci Inputs
Ci   nbas  :size of basis
Ci   ssite :struct containing site-specific information
Ci   leks: :<0 no forces calculated
Ci         : 0 Harris forces only
Ci         :>0 also print HKS forces
Ci         :>1 use HKS forces instead of HF forces
Ci   fes1  :contribution to HF forces from estat + xc potential
Ci   fes2  :contribution to KS forces from estat + xc potential
Ci   dfhf  :2nd order corr. HF forces from ansatz density shift (dfrce)
Cio Inputs/Outputs
Cio     f  :On input, f is the contribution to force from eigval sum
Cio        :On output, f is the total force
Cr Remarks
Cu Updates
Cu   12 Apr 03 Prints out max correction to Harris force
Cu   30 May 00 Adapted from nfp totforce.f
C ----------------------------------------------------------------------
C     implicit none
C ... Passed parameters
      integer nbas,leks
      double precision ssite(*),slat(*),f(3,nbas),fes1(3,nbas),
     .  fes2(3,nbas),dfhf(3,nbas)
C ... Local parameters
      integer stdo,stdl,lgunit,ipr,ipl,ib,m,owk,ng,oistab,og,ibmx,isw
      double precision fev1(3),fev2(3),fhar(3),fks(3),c,ddot,fmax,dfmax
C ... Heap
      integer w(1)
      common /w/ w

      stdo = lgunit(1)
      stdl = lgunit(2)
      if (leks .lt. 0) return
      c = 1000d0
      call getpr(ipr)
      ipl = 1
      fmax = -1
      dfmax = -1

      if (ipr .ge. 30) then
        if (ddot(3*nbas,dfhf,1,dfhf,1) .ne. 0) then
          write(stdo,'(/'' Forces, with eigenvalue correction'')')
        else
          write(stdo,'(/''Forces:'')')
        endif
        write(stdo,201)
  201   format('  ib',11x,'estatic',18x,'eigval',20x,'total')
      endif
      do  ib = 1, nbas
        do  m = 1, 3
          fev1(m) = f(m,ib) + dfhf(m,ib)
          fev2(m) = f(m,ib)
          fhar(m) = fev1(m) + fes1(m,ib)
          f(m,ib) = fhar(m)
        enddo
        if (dsqrt(ddot(3,fhar,1,fhar,1)) .gt. fmax) then
          ibmx = ib
          fmax = dsqrt(ddot(3,fhar,1,fhar,1))
        endif
        if (dsqrt(ddot(3,dfhf(1,ib),1,dfhf(1,ib),1)) .gt. dfmax) then
          ibmx = ib
          dfmax = dsqrt(ddot(3,dfhf(1,ib),1,dfhf(1,ib),1))
        endif
        if (ipr .ge. 30) write(stdo,200) ib,(c*fes1(m,ib),m=1,3),
     .    (c*fev1(m),m=1,3),(c*fhar(m),m=1,3)
  200   format(i4,3f8.2,1x,3f8.2,1x,3f8.2)
        if (leks. eq. 0 .and. ipl .gt. 0 .and. ipr .ge. 30)
     .      write(stdl,710) ib,(c*fhar(m),m=1,3)
        call pack2('site force',ssite,ib,f(1,ib))
  710   format('fp ib',i4,'  fh ',3f8.2,2x,3f8.2)

        if (leks .ge. 1) then
          do  m = 1, 3
            fks(m)  = fev2(m) + fes2(m,ib)
            if (leks .gt. 1) f(m,ib) = fks(m)
            if (leks .gt. 1) call pack2('site force',ssite,ib,fks)
          enddo
          if (ipr .gt. 40) write(stdo,210) (c*fes2(m,ib),m=1,3),
     .       (c*fev2(m),m=1,3),(c*fks(m),m=1,3)
  210     format('  KS',3f8.2,1x,3f8.2,1x,3f8.2)
          if (ipl .gt. 0 .and. ipr .ge.30)
     .       write (stdl,711) ib,(c*fhar(m),m=1,3),(c*fks(m),m=1,3)
  711     format('fp ib',i4,'  fh ',3f8.2,'   fks ',3f8.2)
        endif
      enddo
      call info5(10,0,0,' Maximum Harris force = %;3g mRy/au (site %i)'
     .  //'%?#n#  Max eval correction = %;1d##',
     .  c*fmax,ibmx,isw(dfmax.gt.0),c*dfmax,0)

C     Symmetrize forces to machine precision
      call upack('lat nsgrp oistab osymgr',slat,ng,oistab,og,0,0)
      if (ng .gt. 1) then
      call info(30,1,0,' Symmetrize forces ...',0,0)
      call defdr(owk,3*nbas)
      call symfor(nbas,1,w(og),ng,w(oistab),w(owk),f)
      call rlse(owk)
      endif

      end
