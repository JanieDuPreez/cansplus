subroutine integrate_cyl_mp5_2nd(margin,ix,jx,kx,gm,x,dx,y,dy,z,dz,dt &
     ,gx,gz,floor,ro1,pr1,vx1,vy1,vz1,bx1,by1,bz1,phi1 &
     ,ro,pr,vx,vy,vz,bx,by,bz,phi,ch,cr &
     ,eta0,vc,eta,ccx,ccy,ccz,te_factor,RadCool,time,rohalo,swtch_t)
  use convert
  implicit none

!--Input
  integer,intent(in) :: ix,jx,kx,margin

  real(8),intent(in) :: ch,cr
  real(8) :: cp

  real(8),intent(in) :: dt,gm,eta0,vc
  real(8) :: dts

  real(8),intent(in) :: floor

  real(8),dimension(ix),intent(in) :: x,dx
  real(8),dimension(jx),intent(in) :: y,dy
  real(8),dimension(kx),intent(in) :: z,dz
  real(8),dimension(5,2,ix),intent(in) :: ccx
  real(8),dimension(5,2,jx),intent(in) :: ccy
  real(8),dimension(5,2,kx),intent(in) :: ccz

  real(8),intent(in) :: te_factor,RadCool,time,rohalo,swtch_t

  real(8),dimension(ix,jx,kx),intent(in) :: gx,gz

!-- using flux
  real(8),dimension(ix,jx,kx),intent(in) :: ro1,pr1,vx1,vy1,vz1
  real(8),dimension(ix,jx,kx),intent(in) :: bx1,by1,bz1

  real(8),dimension(ix,jx,kx),intent(in) :: phi1

!-- Input & output
  real(8),dimension(ix,jx,kx) :: ro,pr,vx,vy,vz
  real(8),dimension(ix,jx,kx) :: bx,by,bz

  real(8),dimension(ix,jx,kx) :: phi
  real(8),dimension(ix,jx,kx) :: eta
!--Temporary vari
!  real(8),dimension(ix,jx,kx) :: curx,cury,curz

!-conserved variable
  real(8),dimension(ix,jx,kx) :: rx,ry,rz,ee
  real(8),dimension(ix,jx,kx) :: rx1,ry1,rz1,ee1

!-source
  real(8) :: sro,srx,sry,srz
  real(8) :: see,sphi,sbz

!-surface variables
  real(8),dimension(ix,jx,kx,2) :: row,prw,vxw,vyw,vzw
  real(8),dimension(ix,jx,kx,2) :: bxw,byw,bzw,phiw
  real(8),dimension(ix,jx,kx) :: bx_m,by_m,bz_m,phi_m
  
!-Numerical flux
!x-component
  real(8),dimension(ix,jx,kx) :: frox,feex,frxx,fryx,frzx
  real(8),dimension(ix,jx,kx) :: fbyx,fbzx,fbxx,fphix
!y-component
  real(8),dimension(ix,jx,kx) :: froy,feey,frxy,fryy,frzy
  real(8),dimension(ix,jx,kx) :: fbyy,fbzy,fbxy,fphiy
!z-component
  real(8),dimension(ix,jx,kx) :: froz,feez,frxz,fryz,frzz
  real(8),dimension(ix,jx,kx) :: fbxz,fbyz,fbzz,fphiz

!-other temporary variables

  real(8) :: dtodx,dtody,dtodz

  integer :: mdir
  integer :: i,j,k

  real(8) :: inversex

  real(8) :: pt

  real(8) :: pi,hpi4,inhpi4

  real(8) :: ratio,limit

  real(8) :: te

  ratio=100.0d0
  limit=0.0d0

!-----Step 0.----------------------------------------------------------|
! primitive to conserve
!

  cp = sqrt(ch*cr)
  pi = acos(-1.0d0)
  hpi4 = sqrt(4.0d0*pi)
  inhpi4 = 1.0d0/hpi4

  call convert_ptoc_m(ix,jx,kx,gm,ro,pr,vx,vy,vz,bx,by,bz &
       ,rx,ry,rz,ee)

!  call getcurrent_cyl(bxf,byf,bzf,ix,jx,kx,x,dx,dy,dz &
!       ,curx,cury,curz)
!
!  call getEta(ix,jx,kx,rof,curx,cury,curz,eta0,vc,eta)

!-----Step 1a.---------------------------------------------------------|
! Compute flux in x-direction
! set L/R state at x-direction
!
  mdir = 1

! if (time .gt. swtch_t) then
!  call MP5_reconstruction_charGlmMhd2(mdir,ix,jx,kx,ro1,pr1 &
!       ,vx1,vy1,vz1,bx1,by1,bz1,phi1 &
!       ,ch,gm,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw,ccx,ccy,ccz)
!
!  call MP5toMC2(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir,floor,ratio)

!  call MP5toMC2_2(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir,floor,limit)
! else
!  call MC2_dxyz(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir)
!
  call MC2(ix,jx,kx,x,dx,y,dy,z,dz &
       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
       ,mdir)
! endif
!  call 1D(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir)

  call cal_interface_BP(ix,jx,kx,bxw,phiw &
       ,bx_m,phi_m,ch)
  call glm_flux(bx_m,phi_m,ch,fbxx,fphix,ix,jx,kx)
  
  call hlld_flux(row,prw,vxw,vyw,vzw,bx_m,byw,bzw,gm,ix,jx,kx,floor &
       ,frox,feex,frxx,fryx,frzx,fbyx,fbzx)

!  call cal_resflux(mdir,ix,jx,kx,fbyx,curz,eta,-1.0d0 &
!       ,fbyxr)
!  call cal_resflux(mdir,ix,jx,kx,fbzx,cury,eta,+1.0d0 &
!       ,fbzxr)

!-----Step 1b.---------------------------------------------------------|
! compute flux at y-direction
! set L/R state at y-direction
!
  mdir = 2

! if (time .gt. swtch_t) then
!  call MP5_reconstruction_charGlmMhd2(mdir,ix,jx,kx,ro1,pr1 &
!       ,vy1,vz1,vx1,by1,bz1,bx1,phi1 &
!       ,ch,gm,row,prw,vyw,vzw,vxw,byw,bzw,bxw,phiw,ccx,ccy,ccz)
!
!  call MP5toMC2(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir,floor,ratio)

!  call MP5toMC2_2(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir,floor,limit)
! else
!  call MC2_dxyz(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir)
!
  call MC2(ix,jx,kx,x,dx,y,dy,z,dz &
       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
       ,mdir)
! endif
!  call 1D(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir)

  call cal_interface_BP(ix,jx,kx,byw,phiw &
       ,by_m,phi_m,ch)

  call glm_flux(by_m,phi_m,ch,fbyy,fphiy,ix,jx,kx)

  call hlld_flux(row,prw,vyw,vzw,vxw,by_m,bzw,bxw,gm,ix,jx,kx,floor &
       ,froy,feey,fryy,frzy,frxy,fbzy,fbxy)

!  call cal_resflux(mdir,ix,jx,kx,fbzy,curz,eta,-1.0d0 &
!       ,fbzyr)
!  call cal_resflux(mdir,ix,jx,kx,fbxy,curx,eta,+1.0d0 &
!       ,fbxyr)

!-----Step 1c.---------------------------------------------------------|
! compute flux at z-direction
! set L/R state at z-direction
!
  mdir = 3

! if (time .gt. swtch_t) then
!  call MP5_reconstruction_charGlmMhd2(mdir,ix,jx,kx,ro1,pr1 &
!       ,vz1,vx1,vy1,bz1,bx1,by1,phi1 &
!       ,ch,gm,row,prw,vzw,vxw,vyw,bzw,bxw,byw,phiw,ccx,ccy,ccz)
!
!  call MP5toMC2(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir,floor,ratio)
!
!  call MP5toMC2_2(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir,floor,limit)
! else
!  call MC2_dxyz(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir)
!
  call MC2(ix,jx,kx,x,dx,y,dy,z,dz &
       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
       ,mdir)
! endif
!  call 1D(ix,jx,kx,x,dx,y,dy,z,dz &
!       ,ro,pr,vx,vy,vz,bx,by,bz,phi &
!       ,row,prw,vxw,vyw,vzw,bxw,byw,bzw,phiw &
!       ,mdir)

  call cal_interface_BP(ix,jx,kx,bzw,phiw &
       ,bz_m,phi_m,ch)

  call glm_flux(bz_m,phi_m,ch,fbzz,fphiz,ix,jx,kx)

  call hlld_flux(row,prw,vzw,vxw,vyw,bz_m,bxw,byw,gm,ix,jx,kx,floor &
       ,froz,feez,frzz,frxz,fryz,fbxz,fbyz)

!  call cal_resflux(mdir,ix,jx,kx,fbxz,cury,eta,-1.0d0 &
!       ,fbxzr)
!  call cal_resflux(mdir,ix,jx,kx,fbyz,curx,eta,+1.0d0 &
!       ,fbyzr)


!-----Step 3a.---------------------------------------------------------|
! half time step update cell center variables using x-flux
!
  do k=3,kx-2
     do j=3,jx-2
        do i=3,ix-2
           dtodx = dt/dx(i)
           ro(i,j,k) = ro(i,j,k) + dtodx*(frox(i-1,j,k)-frox(i,j,k))
           ee(i,j,k) = ee(i,j,k) + dtodx*(feex(i-1,j,k)-feex(i,j,k))
           rx(i,j,k) = rx(i,j,k) + dtodx*(frxx(i-1,j,k)-frxx(i,j,k))
           ry(i,j,k) = ry(i,j,k) + dtodx*(fryx(i-1,j,k)-fryx(i,j,k))
           rz(i,j,k) = rz(i,j,k) + dtodx*(frzx(i-1,j,k)-frzx(i,j,k))
           bx(i,j,k) = bx(i,j,k) + dtodx*(fbxx(i-1,j,k)-fbxx(i,j,k))
           by(i,j,k) = by(i,j,k) + dtodx*(fbyx(i-1,j,k)-fbyx(i,j,k))
           bz(i,j,k) = bz(i,j,k) + dtodx*(fbzx(i-1,j,k)-fbzx(i,j,k))
           phi(i,j,k) = phi(i,j,k) + dtodx*(fphix(i-1,j,k)-fphix(i,j,k))
        enddo
     enddo
  enddo

!-----Step 3b.---------------------------------------------------------|
! half time step update cell center variables using z-flux
!

  do k=3,kx-2
     do j=3,jx-2
        do i=3,ix-2
           dtody = dt/(x(i)*dy(j))
           ro(i,j,k) = ro(i,j,k)+dtody*(froy(i,j-1,k)-froy(i,j,k))
           ee(i,j,k) = ee(i,j,k)+dtody*(feey(i,j-1,k)-feey(i,j,k))
           rx(i,j,k) = rx(i,j,k)+dtody*(frxy(i,j-1,k)-frxy(i,j,k))
           ry(i,j,k) = ry(i,j,k)+dtody*(fryy(i,j-1,k)-fryy(i,j,k))
           rz(i,j,k) = rz(i,j,k)+dtody*(frzy(i,j-1,k)-frzy(i,j,k))
           bx(i,j,k) = bx(i,j,k)+dtody*(fbxy(i,j-1,k)-fbxy(i,j,k))
           bz(i,j,k) = bz(i,j,k)+dtody*(fbzy(i,j-1,k)-fbzy(i,j,k))
           by(i,j,k) = by(i,j,k)+dtody*(fbyy(i,j-1,k)-fbyy(i,j,k))
           phi(i,j,k) = phi(i,j,k)+dtody*(fphiy(i,j-1,k)-fphiy(i,j,k))
        enddo
     enddo
  enddo

!-----Step 3c.---------------------------------------------------------|
! half time step update cell center variables using z-flux
!

  do k=3,kx-2
     do j=3,jx-2
        do i=3,ix-2
           dtodz = dt/dz(k)
           ro(i,j,k) = ro(i,j,k)+dtodz*(froz(i,j,k-1)-froz(i,j,k))
           ee(i,j,k) = ee(i,j,k)+dtodz*(feez(i,j,k-1)-feez(i,j,k))
           rx(i,j,k) = rx(i,j,k)+dtodz*(frxz(i,j,k-1)-frxz(i,j,k))
           ry(i,j,k) = ry(i,j,k)+dtodz*(fryz(i,j,k-1)-fryz(i,j,k))
           rz(i,j,k) = rz(i,j,k)+dtodz*(frzz(i,j,k-1)-frzz(i,j,k))
           bx(i,j,k) = bx(i,j,k)+dtodz*(fbxz(i,j,k-1)-fbxz(i,j,k))
           by(i,j,k) = by(i,j,k)+dtodz*(fbyz(i,j,k-1)-fbyz(i,j,k))
           bz(i,j,k) = bz(i,j,k)+dtodz*(fbzz(i,j,k-1)-fbzz(i,j,k))
           phi(i,j,k) = phi(i,j,k)+dtodz*(fphiz(i,j,k-1)-fphiz(i,j,k))
        enddo
     enddo
  enddo

!-----Step 2.----------------------------------------------------------|
! add source term
! 

  do k=3,kx-2
     do j=3,jx-2
        do i=3,ix-2
           inversex = 1.0d0/x(i)
! density
           sro = -0.5d0*(frox(i,j,k)+frox(i-1,j,k))*inversex
           ro(i,j,k) = ro(i,j,k)+dt*sro
! x-momentum
           srx = -(ro1(i,j,k)*(vx1(i,j,k)**2-vy1(i,j,k)**2) &
                +(by1(i,j,k)**2-bx1(i,j,k)**2))*inversex &
                +ro1(i,j,k)*gx(i,j,k)
           rx(i,j,k) = rx(i,j,k)+dt*srx
! y-momentum
           sry = -(fryx(i,j,k)+fryx(i-1,j,k))*inversex
           ry(i,j,k) = ry(i,j,k)+dt*sry
! z-momentum
           srz = -0.5d0*(frzx(i,j,k)+frzx(i-1,j,k))*inversex &
                + ro1(i,j,k)*gz(i,j,k)
           rz(i,j,k) = rz(i,j,k)+dt*srz
! z-magnetic
           sbz = -0.5d0*(fbzx(i-1,j,k)+fbzx(i,j,k))*inversex
           bz(i,j,k) = bz(i,j,k)+dt*sbz
! energy
           see = -0.5d0*(feex(i,j,k)+feex(i-1,j,k))*inversex &
                +ro1(i,j,k)*(vx1(i,j,k)*gx(i,j,k)+vz1(i,j,k)*gz(i,j,k))
!           if (time .gt. swtch_t) then
			  if (ro(i,j,k) .gt. rohalo) then
                te = te_factor*pr(i,j,k)/ro(i,j,k)
                see = see - RadCool*(ro(i,j,k)**2)*sqrt(te)
			  endif
!           endif
           ee(i,j,k) = ee(i,j,k)+dt*see
! phi
           sphi = -0.5d0*(fphix(i,j,k)+fphix(i-1,j,k))*inversex
           phi(i,j,k) = phi(i,j,k)+dt*sphi
           phi(i,j,k) = phi(i,j,k)*exp(-dt*ch**2/cp**2)
        end do
     end do
  end do

!-----Step 5.----------------------------------------------------------|
! conserved to primitive
!
  call convert_ctop_m(ix,jx,kx,gm,ro,ee,rx,ry,rz,bx,by,bz,floor &
       ,vx,vy,vz,pr)

  return
end subroutine integrate_cyl_mp5_2nd
