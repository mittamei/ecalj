      SUBROUTINE CCUTUP(B0,B,IBTR,KCUT)
      IMPLICIT double precision (A-H,O-Z)
      DIMENSION B(3,3),IBTR(3,3),B0(3,3),KCUT0(3,4,6),KCUT(3,4,6),
     .SHIFT(3),P(3,4)
      DATA KCUT0/
     .0,0,0, 0,1,0, 1,1,0, 1,1,1,  0,0,0, 1,0,0, 1,1,0, 1,1,1,
     .0,0,0, 1,0,0, 1,0,1, 1,1,1,  0,0,0, 0,1,0, 0,1,1, 1,1,1,
     .0,0,0, 0,0,1, 0,1,1, 1,1,1,  0,0,0, 0,0,1, 1,0,1, 1,1,1 /
      DATA SHIFT/0.D0,0.D0,0.D0/
      ANRM2(X,Y,Z)=X*X*1.00001D0+Y*Y*1.00002D0+Z*Z*1.00003D0
     .-X*0.000004D0-Y*0.000003D0-Z*0.000002D0
C ------ CALL CSHEAR TO GET MOST COMPACT CELL (doesn't work) --------
      CALL CSHEAR(B0,B,IBTR)
C ----- CHOSE CUTUP WITH SHORTEST MAX EDGE ---------
      if (iprint() .gt. 100) WRITE(*,*) 'CUTUP : '
      LZ = 0
      LXX = 0
      LYY = 0
      EDGMAX = 1.D20
      EDGMIN = 0.D0
      DO  10  LX = 0, 1
      DO  10  LY = 0, 1
        DO  12  ITET = 1, 6
        DO  12  IC = 1, 4
          CALL MXMYMZ(KCUT0(1,IC,ITET),KCUT(1,IC,ITET),LX,LY,LZ)
   12   continue
        EDMIN = 1D20
        EDMAX = 0D0
        DO  20  ITET = 1, 6
          DO  21  IC = 1, 4
            CALL GTBVEC(KCUT(1,IC,ITET),B,SHIFT,P(1,IC))
   21     continue
          DO  13  I = 1, 3
          DO  13  J = I+1, 4
            XX = ANRM2(P(1,I)-P(1,J),P(2,I)-P(2,J),P(3,I)-P(3,J))
            EDMAX = DMAX1(EDMAX,XX)
            EDMIN = DMIN1(EDMIN,XX)
   13     continue
   20   CONTINUE
        if (iprint() .gt. 100)
     .WRITE(*,706) LX,LY,DSQRT(EDMIN),DSQRT(EDMAX)
  706   FORMAT(' LX,LY=',2I5,'   EDMIN=',F10.5,'   EDMAX=',F10.5)
        IF (EDMAX .LT. EDGMAX) THEN
          LXX = LX
          LYY = LY
          EDGMAX = EDMAX
          EDGMIN = EDMIN
        ENDIF
   10 CONTINUE
      DO  22  ITET = 1, 6
      DO  22  IC = 1, 4
        CALL MXMYMZ(KCUT0(1,IC,ITET),KCUT(1,IC,ITET),LXX,LYY,LZ)
   22 continue
      if (iprint() .gt. 100)
     .WRITE(*,783) LXX,LYY,DSQRT(EDGMIN),DSQRT(EDGMAX)
  783 FORMAT(' LXX=',I1,'   LYY=',I1,'   EDGMIN=',F10.5,
     .'   EDGMAX=',F10.5)

      END

