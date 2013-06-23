subroutine MP5toMC2_2(ix,jx,kx,x,dx,y,dy,z,dz &
     ,ro,pr,vx,vy,vz,bx,by,bz,phi &
     ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
     ,mdir,floor,ratio)
  implicit none

  integer,intent(in) :: ix,jx,kx

  real(8),dimension(ix),intent(in) :: x,dx
  real(8),dimension(jx),intent(in) :: y,dy
  real(8),dimension(kx),intent(in) :: z,dz

  real(8),dimension(ix,jx,kx),intent(in) :: ro,pr,vx,vy,vz
  real(8),dimension(ix,jx,kx),intent(in) :: bx,by,bz

  real(8),dimension(ix,jx,kx),intent(in) :: phi

  real(8),dimension(ix,jx,kx,2) :: row,prw,vxw,vyw,vzw
  real(8),dimension(ix,jx,kx,2) :: bxw,byw,bzw,phiw

  integer :: mdir

  real(8),intent(in) :: floor,ratio

  call switchMP5toMC2_2(mdir,ix,jx,kx,ro,ro &
       ,row,floor,ratio)

  call switchMP5toMC2_2(mdir,ix,jx,kx,ro,pr &
       ,prw,floor,ratio)

  call switchMP5toMC2_2(mdir,ix,jx,kx,ro,vx &
       ,vxw,floor,ratio)

  call switchMP5toMC2_2(mdir,ix,jx,kx,ro,vy &
       ,vyw,floor,ratio)

  call switchMP5toMC2_2(mdir,ix,jx,kx,ro,vz &
       ,vzw,floor,ratio)

  call switchMP5toMC2_2(mdir,ix,jx,kx,ro,bx &
       ,bxw,floor,ratio)

  call switchMP5toMC2_2(mdir,ix,jx,kx,ro,by &
       ,byw,floor,ratio)

  call switchMP5toMC2_2(mdir,ix,jx,kx,ro,bz &
       ,bzw,floor,ratio)

  call switchMP5toMC2_2(mdir,ix,jx,kx,ro,phi &
       ,phiw,floor,ratio)

  return
end subroutine MP5toMC2_2
