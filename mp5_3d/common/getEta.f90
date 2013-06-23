!
! calculate anomourous resistivity (eta)
!
subroutine getEta(ix,jx,kx,ro,curx,cury,curz,eta0,vc,eta)

  implicit none

  integer,intent(in) :: ix,jx,kx

! eta0 :: upper limit of resistivity
! vc   :: threshold 
  real(8),intent(in) :: eta0,vc

  real(8),dimension(ix,jx,kx),intent(in) :: curx,cury,curz
  real(8),dimension(ix,jx,kx),intent(in) :: ro

  real(8),dimension(ix,jx,kx) :: eta

! vd :: current density (?)
  real(8) :: cur_abs,vd,etamax
  integer :: i,j,k
  
!  etamax=eta0*100.0d0
  etamax=0.01d0
  do k=2,kx-1
     do j=2,jx-1
        do i=2,ix-1
           cur_abs = sqrt(curx(i,j,k)**2 &
                +cury(i,j,k)**2+curz(i,j,k)**2)
           vd = cur_abs/ro(i,j,k)

           eta(i,j,k) = min(etamax,eta0*(max((vd/vc-1.0d0),0.0d0)**2))
        end do
     end do
  end do

  return
end subroutine getEta
