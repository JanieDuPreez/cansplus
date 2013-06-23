subroutine hancock_diff_e(mdir,ix,jx,kx,gm,ch,ro,pr,vx,vy,vz,bx,by,bz,phi &
     ,roHDiff,prHDiff,vxHDiff,vyHDiff,vzHDiff,bxHDiff,byHDiff,bzHDiff &
     ,phiHDiff,floor)
  implicit none

!---Input
  integer,intent(in) :: mdir
  integer,intent(in) :: ix,jx,kx

  real(8),intent(in) :: gm,ch,floor

  real(8),dimension(ix,jx,kx),intent(in) :: ro,pr
  real(8),dimension(ix,jx,kx),intent(in) :: vx,vy,vz
  real(8),dimension(ix,jx,kx),intent(in) :: bx,by,bz
  real(8),dimension(ix,jx,kx),intent(in) :: phi

  real(8),dimension(ix,jx,kx),intent(inout) :: roHDiff,prHDiff
  real(8),dimension(ix,jx,kx),intent(inout) :: vxHDiff,vyHDiff,vzHDiff
  real(8),dimension(ix,jx,kx),intent(inout) :: bxHDiff,byHDiff,bzHDiff
  real(8),dimension(ix,jx,kx),intent(inout) :: phiHDiff

  integer,parameter :: nWave = 9
  real(8),dimension(nWave) :: ww,aa,dwl,dwr,dal,dar,da,dw
  real(8),dimension(nWave,nWave) :: rem,lem

  real(8) :: temp

  integer :: i,j,k,l,m

  integer,parameter :: itest = 57,jtest = 56,ktest = 3
  if(mdir .eq. 1)then
  do k=2,kx-1
     do j=2,jx-1
        do i=2,ix-1
!----
! step 1 cal.eigen Matrix
           call getEigenMatric(nWave,gm,ch,floor,ro(i,j,k),vx(i,j,k),vy(i,j,k),vz(i,j,k) &
                ,pr(i,j,k),bx(i,j,k),by(i,j,k),bz(i,j,k),phi(i,j,k),rem,lem)
!----
! step 2 cal.eigen Matrix

           ww(1) = ro(i,j,k)
           ww(2) = vx(i,j,k)
           ww(3) = vy(i,j,k)
           ww(4) = vz(i,j,k)
           ww(5) = pr(i,j,k)
           ww(6) = bx(i,j,k)
           ww(7) = by(i,j,k)
           ww(8) = bz(i,j,k)
           ww(9) = phi(i,j,k)


           dwl(1) = ro(i,j,k)-ro(i-1,j,k)
           dwl(2) = vx(i,j,k)-vx(i-1,j,k)
           dwl(3) = vy(i,j,k)-vy(i-1,j,k)
           dwl(4) = vz(i,j,k)-vz(i-1,j,k)
           dwl(5) = pr(i,j,k)-pr(i-1,j,k)           
           dwl(6) = bx(i,j,k)-bx(i-1,j,k)
           dwl(7) = by(i,j,k)-by(i-1,j,k)
           dwl(8) = bz(i,j,k)-bz(i-1,j,k)
           dwl(9) = phi(i,j,k)-phi(i-1,j,k)

           dwr(1) = ro(i+1,j,k)-ro(i,j,k)
           dwr(2) = vx(i+1,j,k)-vx(i,j,k)
           dwr(3) = vy(i+1,j,k)-vy(i,j,k)
           dwr(4) = vz(i+1,j,k)-vz(i,j,k)
           dwr(5) = pr(i+1,j,k)-pr(i,j,k)           
           dwr(6) = bx(i+1,j,k)-bx(i,j,k)
           dwr(7) = by(i+1,j,k)-by(i,j,k)
           dwr(8) = bz(i+1,j,k)-bz(i,j,k)
           dwr(9) = phi(i+1,j,k)-phi(i,j,k)

           do l=1,nWave
              dal(l) = 0.0d0
              dar(l) = 0.0d0
           end do

           do l=1,nWave
              do m=1,nWave
                 dal(l) = dal(l) + lem(l,m)*dwl(m)
                 dar(l) = dar(l) + lem(l,m)*dwr(m)
              end do
           end do
!----
! step 3 apply minmod
           do l=1,nWave
              da(l) = ave(dal(l),dar(l))
           end do

!----
! step 4 convert primitive
           do l=1,nWave
              dw(l) = 0.0d0
           end do

           do l=1,nWave
              do m=1,nWave
                 dw(l) = dw(l) + da(m)*rem(m,l)
              end do
           end do

           roHDiff(i,j,k) = dw(1)
           vxHDiff(i,j,k) = dw(2)
           vyHDiff(i,j,k) = dw(3)
           vzHDiff(i,j,k) = dw(4)
           prHDiff(i,j,k) = dw(5)
           bxHDiff(i,j,k) = dw(6)
           byHDiff(i,j,k) = dw(7)
           bzHDiff(i,j,k) = dw(8)
           phiHDiff(i,j,k) = dw(9)
        end do
     end do
  end do
  else if(mdir .eq. 2)then
  do k=2,kx-1
     do j=2,jx-1
        do i=2,ix-1
!----
! step 1 cal.eigen Matrix
           call getEigenMatric(nWave,gm,ch,floor,ro(i,j,k),vy(i,j,k),vz(i,j,k),vx(i,j,k) &
                ,pr(i,j,k),by(i,j,k),bz(i,j,k),bx(i,j,k),phi(i,j,k),rem,lem)

!----
! step 2 cal.eigen Matrix

           ww(1) = ro(i,j,k)
           ww(2) = vy(i,j,k)
           ww(3) = vz(i,j,k)
           ww(4) = vx(i,j,k)
           ww(5) = pr(i,j,k)
           ww(6) = by(i,j,k)
           ww(7) = bz(i,j,k)
           ww(8) = bx(i,j,k)
           ww(9) = phi(i,j,k)

           dwl(1) = ro(i,j,k)-ro(i,j-1,k)
           dwl(2) = vy(i,j,k)-vy(i,j-1,k)
           dwl(3) = vz(i,j,k)-vz(i,j-1,k)
           dwl(4) = vx(i,j,k)-vx(i,j-1,k)
           dwl(5) = pr(i,j,k)-pr(i,j-1,k)           
           dwl(6) = by(i,j,k)-by(i,j-1,k)
           dwl(7) = bz(i,j,k)-bz(i,j-1,k)
           dwl(8) = bx(i,j,k)-bx(i,j-1,k)
           dwl(9) = phi(i,j,k)-phi(i,j-1,k)

           dwr(1) = ro(i,j+1,k)-ro(i,j,k)
           dwr(2) = vy(i,j+1,k)-vy(i,j,k)
           dwr(3) = vz(i,j+1,k)-vz(i,j,k)
           dwr(4) = vx(i,j+1,k)-vx(i,j,k)
           dwr(5) = pr(i,j+1,k)-pr(i,j,k)           
           dwr(6) = by(i,j+1,k)-by(i,j,k)
           dwr(7) = bz(i,j+1,k)-bz(i,j,k)
           dwr(8) = bx(i,j+1,k)-bx(i,j,k)
           dwr(9) = phi(i,j+1,k)-phi(i,j,k)

           do l=1,nWave
              dal(l) = 0.0d0
              dar(l) = 0.0d0
           end do

           do l=1,nWave
              do m=1,nWave
                 dal(l) = dal(l) + lem(l,m)*dwl(m)
                 dar(l) = dar(l) + lem(l,m)*dwr(m)
              end do
           end do

!----
! step 3 apply minmod
           do l=1,nWave
              da(l) = ave(dal(l),dar(l))
           end do

!----
! step 4 convert primitive
           do l=1,nWave
              dw(l) = 0.0d0
           end do

           do l=1,nWave
              do m=1,nWave
                 dw(l) = dw(l) + da(m)*rem(m,l)
              end do
           end do

           roHDiff(i,j,k) = dw(1)
           vyHDiff(i,j,k) = dw(2)
           vzHDiff(i,j,k) = dw(3)
           vxHDiff(i,j,k) = dw(4)
           prHDiff(i,j,k) = dw(5)
           byHDiff(i,j,k) = dw(6)
           bzHDiff(i,j,k) = dw(7)
           bxHDiff(i,j,k) = dw(8)
           phiHDiff(i,j,k) = dw(9)
        end do
     end do
  end do
  else
  do k=2,kx-1
     do j=2,jx-1
        do i=2,ix-1
!----
! step 1 cal.eigen Matrix
           call getEigenMatric(nWave,gm,ch,floor,ro(i,j,k),vz(i,j,k),vx(i,j,k),vy(i,j,k) &
                ,pr(i,j,k),bz(i,j,k),bx(i,j,k),by(i,j,k),phi(i,j,k),rem,lem)

!----
! step 2 cal.eigen Matrix

           ww(1) = ro(i,j,k)
           ww(2) = vz(i,j,k)
           ww(3) = vx(i,j,k)
           ww(4) = vy(i,j,k)
           ww(5) = pr(i,j,k)
           ww(6) = bz(i,j,k)
           ww(7) = bx(i,j,k)
           ww(8) = by(i,j,k)
           ww(9) = phi(i,j,k)

           dwl(1) = ro(i,j,k)-ro(i,j,k-1)
           dwl(2) = vz(i,j,k)-vz(i,j,k-1)
           dwl(3) = vx(i,j,k)-vx(i,j,k-1)
           dwl(4) = vy(i,j,k)-vy(i,j,k-1)
           dwl(5) = pr(i,j,k)-pr(i,j,k-1)           
           dwl(6) = bz(i,j,k)-bz(i,j,k-1)
           dwl(7) = bx(i,j,k)-bx(i,j,k-1)
           dwl(8) = by(i,j,k)-by(i,j,k-1)
           dwl(9) = phi(i,j,k)-phi(i,j,k-1)

           dwr(1) = ro(i,j,k+1)-ro(i,j,k)
           dwr(2) = vz(i,j,k+1)-vz(i,j,k)
           dwr(3) = vx(i,j,k+1)-vx(i,j,k)
           dwr(4) = vy(i,j,k+1)-vy(i,j,k)
           dwr(5) = pr(i,j,k+1)-pr(i,j,k)           
           dwr(6) = bz(i,j,k+1)-bz(i,j,k)
           dwr(7) = bx(i,j,k+1)-bx(i,j,k)
           dwr(8) = by(i,j,k+1)-by(i,j,k)
           dwr(9) = phi(i,j,k+1)-phi(i,j,k)

           do l=1,nWave
              dal(l) = 0.0d0
              dar(l) = 0.0d0
           end do

           do l=1,nWave
              do m=1,nWave
                 dal(l) = dal(l) + lem(l,m)*dwl(m)
                 dar(l) = dar(l) + lem(l,m)*dwr(m)
              end do
           end do
!----
! step 3 apply minmod
           do l=1,nWave
              da(l) = ave(dal(l),dar(l))
           end do

!----
! step 4 convert primitive
           do l=1,nWave
              dw(l) = 0.0d0
           end do

           do l=1,nWave
              do m=1,nWave
                 dw(l) = dw(l) + da(m)*rem(m,l)
              end do
           end do

           roHDiff(i,j,k) = dw(1)
           vzHDiff(i,j,k) = dw(2)
           vxHDiff(i,j,k) = dw(3)
           vyHDiff(i,j,k) = dw(4)
           prHDiff(i,j,k) = dw(5)
           bzHDiff(i,j,k) = dw(6)
           bxHDiff(i,j,k) = dw(7)
           byHDiff(i,j,k) = dw(8)
           phiHDiff(i,j,k) = dw(9)
        end do
     end do
  end do
  end if
  return
contains
  subroutine getEigenMatric(nWave,gm,ch,floor,ro,vx,vy,vz,pr,bx,by,bz,phi,rem,lem)
    implicit none

    integer,intent(in) :: nWave
    
    real(8),intent(in) :: ro,vx,vy,vz
    real(8),intent(in) :: pr,bx,by,bz,phi

    real(8),intent(in) :: gm,ch,floor

    real(8),dimension(nWave,nWave),intent(inout) :: lem,rem

    real(8) :: aasq,cfsq,cssq,casq,ctsq
    real(8) :: cf,cs,aa

    real(8) :: alf,als,betay,betaz
    real(8) :: qf,qs
    real(8) :: af,as,aff,ass
    real(8) :: nn

    real(8) :: roi,vaxsq
    
    real(8) :: btsq,bxsign
    real(8) :: sqrtro
    real(8) :: temp,temp_sum,temp_diff

    real(8) :: cf2_cs2,bt

    real(8),dimension(nWave,nWave) :: em

    integer :: i,j,k,l,m

    roi = 1.0d0/ro
    btsq = by**2+bz**2
    vaxsq = roi*bx**2
    aasq = gm*pr*roi

    ctsq = btsq*roi
    temp_sum = ctsq + vaxsq + aasq
    temp_diff = ctsq + vaxsq - aasq

    cf2_cs2 = sqrt(dabs((temp_diff**2+4.0d0*aasq*ctsq)))

    cfsq = 0.5d0*dabs(temp_sum+cf2_cs2)
    cf = sqrt(cfsq)
    cssq = aasq*vaxsq/cfsq
    cs = sqrt(dabs(cssq))

    bt = sqrt(btsq)
    if(bt < floor)then
       betay = 1.0d0
       betaz = 0.0d0
    else
       betay = by/bt
       betaz = bz/bt
    endif

    if(cf2_cs2 < floor)then
       alf = 1.0d0
       als = 0.0d0
    else if((aasq-cssq) <= 0.0d0)then
       alf = 0.0d0
       als = 1.0d0
    else if((cfsq - aasq) <= 0.0d0)then
       alf = 1.0d0
       als = 0.0d0
    else
       alf = sqrt(dabs(aasq-cssq)/cf2_cs2)
       als = sqrt(dabs(cfsq-aasq)/cf2_cs2)
    endif

    bxsign = sign(1.0d0,bx)
    sqrtro = sqrt(ro)
    aa = sqrt(aasq)
    qf = cf*alf*bxsign
    qs = cs*als*bxsign
    af = aa*alf*sqrtro
    as = aa*alf*sqrtro

    do j=1,nWave
       do i=1,nWave
          lem(i,j) = 0.0d0
          rem(i,j) = 0.0d0
       end do
    end do

    rem(1,1) = ro*alf
    rem(1,3) = ro*als
    rem(1,4) = 1.0d0
    rem(1,5) = rem(1,3)
    rem(1,8) = rem(1,1)

    rem(2,1) = -cf*alf
    rem(2,3) = -cs*als
    rem(2,5) = -rem(2,3)
    rem(2,8) = -rem(2,1)

    rem(3,1) = qs*betay
    rem(3,2) = -betaz
    rem(3,3) = -qf*betay
    rem(3,5) = -rem(3,3)
    rem(3,7) = betaz
    rem(3,8) = -rem(3,1)

    rem(4,1) = qs*betaz
    rem(4,2) = betay
    rem(4,3) = -qf*betaz
    rem(4,5) = -rem(4,3)
    rem(4,7) = -betay
    rem(4,8) = -rem(4,1)

    rem(5,1) = ro*aasq*alf
    rem(5,3) = ro*aasq*als
    rem(5,5) = rem(5,3)
    rem(5,8) = rem(5,1)

    rem(6,6) = 1.0d0
    rem(6,9) = 1.0d0

    rem(7,1) = as*betay
    rem(7,2) = -betaz*bxsign*sqrtro
    rem(7,3) = -af*betay
    rem(7,5) = rem(7,3)
    rem(7,7) = rem(7,2)
    rem(7,8) = rem(7,1)

    rem(8,1) = as*betaz
    rem(8,2) = betay*bxsign*sqrtro
    rem(8,3) = -af*betaz
    rem(8,5) = rem(8,3)
    rem(8,7) = rem(8,2)
    rem(8,8) = rem(8,1)

    rem(9,6) = -ch
    rem(9,9) = ch

    nn = 0.5d0/aasq
    qf = nn*qf
    qs = nn*qs
    aff = nn*af*roi
    ass = nn*as*roi

    lem(1,2) = -nn*cf*alf
    lem(1,3) = qs*betay
    lem(1,4) = qs*betaz
    lem(1,5) = nn*alf*roi
    lem(1,7) = ass*betay
    lem(1,8) = ass*betaz
    
    lem(2,3) = -0.5d0*betaz
    lem(2,4) = 0.5d0*betay
    lem(2,7) = -0.5d0*betaz*bxsign/sqrtro
    lem(2,8) = 0.5d0*betay*bxsign/sqrtro

    lem(3,2) = -nn*cs*als
    lem(3,3) = -qf*betay
    lem(3,4) = -qf*betaz
    lem(3,5) = nn*als*roi
    lem(3,7) = -aff*betay
    lem(3,8) = -aff*betaz

    lem(4,1) = 1.0d0
    lem(4,5) = -1.0d0/aasq

    lem(5,2) = -lem(3,2)
    lem(5,3) = -lem(3,3)
    lem(5,4) = -lem(3,4)
    lem(5,5) = lem(3,5)
    lem(5,7) = lem(3,7)
    lem(5,8) = lem(3,8)

    lem(6,6) = 0.5d0
    lem(6,9) = -0.5d0/ch

    lem(7,3) = -lem(2,3)
    lem(7,4) = -lem(2,4)
    lem(7,7) = lem(2,7)
    lem(7,8) = lem(2,8)

    lem(8,2) = -lem(1,2)
    lem(8,3) = -lem(1,3)
    lem(8,4) = -lem(1,4)
    lem(8,5) = lem(1,5)
    lem(8,7) = lem(1,7)
    lem(8,8) = lem(1,8)

    lem(9,6) = lem(6,6)
    lem(9,9) = -lem(6,9)

!!$    do k=1,nWave
!!$       do j=1,nWave
!!$          temp = 0.0d0
!!$          do i=1,nWave
!!$             temp = temp+lem(j,i)*rem(i,k)
!!$          enddo
!!$          em(j,k) = temp
!!$       enddo
!!$    enddo
!!$
!!$    do j=1,nWave
!!$       do i=1,nWave
!!$          if(i == j)then
!!$             if((dabs(em(i,j))-1.0d0) .ge. 1.0d-5)then
!!$                write(*,*) 'taikaku'
!!$                write(*,*) i,j,em(i,j)
!!$             end if
!!$          end if
!!$
!!$          if(i .ne. j)then
!!$             if((dabs(em(i,j)) .ge. 1.0d-5))then
!!$                write(*,*) 'hitaikaku'
!!$                write(*,*) i,j,em(i,j)
!!$             end if
!!$          end if
!!$       end do
!!$    end do
    return
  end subroutine getEigenMatric

  function minmod_limiter(qqr,qql)
    implicit none
    real(8) :: qqr, qql
    real(8) :: minmod_limiter

!    minmod_limiter = max(0.0d0, min(dabs(qqr),qql*sign(1.0d0,qqr)))*sign(1.0d0,qqr)
    if(qqr > 0.0d0)then
       minmod_limiter = max(0.0d0,min(qql,qqr))
    else
       minmod_limiter = min(0.0d0,max(qql,qqr))
    endif

    return
  end function minmod_limiter    

  function ave(qqr,qql)
    implicit none
    real(8) :: qqr, qql
    real(8) :: minmod_lr
    real(8) :: ave

    ave = minmod_limiter(qqr,qql)
!!$    if(qql*qqr > 0.0d0)then
!!$       minmod_lr = minmod_limiter(qql,qqr)
!!$       ave = minmod_limiter(0.5d0*(qql+qqr),minmod_lr)
!!$    else
!!$       ave = 0.0d0
!!$    end if
    return
  end function ave

end subroutine hancock_diff_e
