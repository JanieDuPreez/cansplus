subroutine lr_state_MC2_dxyz(mdir,ix,jx,kx,dx,dy,dz,qq &
     ,qqw)
!======================================================================
! Name :: lr_state_minmod
!         flux limiter :: minmod
! Input :: 
!         mdir :: direction 1:x, 2:y, 3:z
!         ix,jx,kx :: array size
!         qq :: variables
! Output :: 
!         qqw :: qqw(1) :: left state
!                qqw(2) :: right state
!
!======================================================================
  implicit none

!---Input
  integer,intent(in) :: mdir
  integer,intent(in) :: ix,jx,kx

  real(8),dimension(ix),intent(in) :: dx
  real(8),dimension(jx),intent(in) :: dy
  real(8),dimension(kx),intent(in) :: dz
  
  real(8),dimension(ix,jx,kx) :: qq

!---Output
  real(8),dimension(ix,jx,kx,2) :: qqw

!---Temporary
  real(8) :: dqqx,dqqy,dqqz

  real(8) :: dqc,dql,dqr

  real(8) :: dxc,dxl,dxr
  real(8) :: dyc,dyl,dyr
  real(8) :: dzc,dzl,dzr

  real(8) :: temp

  integer :: i,j,k

!-----Step 1a.-------------------------------------------------|
! dqq
!
!-----Step 1b.-------------------------------------------------|
! mdir = 1 :: x-direction
!

  if(mdir .eq. 1)then
     do k=2,kx-1
        do j=2,jx-1
           do i=2,ix-1
              
              dxl = 0.5d0*(dx(i)+dx(i-1))
              dxr = 0.5d0*(dx(i+1)+dx(i))
              dxc = dxl+dxr

              dql = (qq(i,j,k)-qq(i-1,j,k))/dxl
              dqr = (qq(i+1,j,k)-qq(i,j,k))/dxr
              dqc = (qq(i+1,j,k)-qq(i-1,j,k))/dxc

              dqqx = MC_limiter(dqc,dqr,dql)
              
              qqw(i,j,k,1) = qq(i,j,k) + 0.5d0*dqqx*dx(i)
              
              qqw(i-1,j,k,2) = qq(i,j,k) - 0.5d0*dqqx*dx(i)
              
           enddo
        enddo
     enddo
!-----Step 1b.-------------------------------------------------|
! mdir = 2 :: y-direction
!
  else if(mdir .eq. 2)then
     do k=2,kx-1
        do j=2,jx-1
           do i=2,ix-1
              dql = qq(i,j,k)-qq(i,j-1,k)
              dqr = qq(i,j+1,k)-qq(i,j,k)
              dqc = 0.5d0*(qq(i,j+1,k)-qq(i,j-1,k))

              dqqy = MC_limiter(dqc,dqr,dql)
              
              qqw(i,j,k,1) = qq(i,j,k) + 0.5d0*dqqy
              
              qqw(i,j-1,k,2) = qq(i,j,k) - 0.5d0*dqqy
              
           end do
        end do
     end do
  else
!-----Step 3a.-------------------------------------------------|
! dqq
!
     do k=2,kx-1
        do j=2,jx-1
           do i=2,ix-1

              dzl = 0.5d0*(dz(k)+dz(k-1))
              dzr = 0.5d0*(dz(k+1)+dz(k))
              dzc = dzl+dzr

              dql = (qq(i,j,k)-qq(i,j,k-1))/dzl
              dqr = (qq(i,j,k+1)-qq(i,j,k))/dzr
              dqc = (qq(i,j,k+1)-qq(i,j,k-1))/dzc


              dqqz = MC_limiter(dqc,dqr,dql)
           
              qqw(i,j,k,1) = qq(i,j,k) + 0.5d0*dqqz*dz(k)
              
              qqw(i,j,k-1,2) = qq(i,j,k) - 0.5d0*dqqz*dz(k)
           end do
        end do
     end do
  endif
  return

contains
  function minmod_limiter(qqr,qql)
    implicit none
    
    real(8) :: qqr,qql
    real(8) :: minmod_limiter

    minmod_limiter = max(0.0d0, min(dabs(qqr),qql*sign(1.0d0,qqr)))*sign(1.0d0,qqr)
    return
  end function minmod_limiter

  function minmod_limiter2(qqr,qql)
    implicit none

    real(8) :: qqr, qql
    real(8) :: minmod_limiter2

    real(8) :: signr,signlr

    signr = sign(1.0d0,qqr)
    signlr = sign(1.0d0,(qqr*qql))

    minmod_limiter2 = max(signlr,0.0d0)*( &
         max(signr,0.0d0)*max(0.0d0,min(qql,qqr)) &
         -min(signr,0.0d0)*min(0.0d0,max(qql,qqr)))
!!$    if(qqr > 0.0d0)then
!!$       minmod_limiter2 = max(0.0d0,min(qql,qqr))
!!$    else
!!$       minmod_limiter2 = min(0.0d0,max(qql,qqr))
!!$    endif

    return
  end function minmod_limiter2
  
  function MC_limiter(qqc,qql,qqr)
    implicit none

    real(8) :: qqr,qql,qqc
    real(8) :: minmod_lr
    real(8) :: MC_limiter

    real(8) :: signlr,signMC
!!$    minmod_lr = minmod_limiter(2.0d0*qql,2.0d0*qqr)
!    MC_limiter = minmod_limiter2(0.5d0*qqc,minmod_lr)

    minmod_lr = minmod_limiter2(qql,qqr)

    signlr = sign(1.0d0,(qqc*minmod_lr))
    signMC = sign(1.0d0,(dabs(qqc)-dabs(2.0d0*minmod_lr)))

    MC_limiter = max(signlr,0.0d0)*( &
         max(signMC,0.0d0)*minmod_lr &
         -min(signMC,0.0d0)*(qqc))
    
!!$    if((qqc*minmod_lr) < 0.0d0)then
!!$       MC_limiter = 0.0d0
!!$    else
!!$       if(dabs(0.5d0*qqc) < dabs(2.0d0*minmod_lr))then
!!$          MC_limiter = 0.5d0*qqc
!!$       else
!!$          MC_limiter = minmod_lr
!!$       endif
!!$    endif
    return
  end function MC_limiter
end subroutine lr_state_MC2_dxyz
