create database QLTiemThuoc

use QLTiemThuoc

create table Luongcoban
(
	maluong varchar(30) not null primary key,
	ten nvarchar(50) not null,
	tien money not null
)

create table taikhoan
(
	ten varchar(30) not null primary key,
	matkhau varchar(30) not null,
	chucvu varchar(30) not null
)

create table thanhvien
(
	matv varchar(30) not null primary key,
	ten nvarchar(50) not null,
	tuoi int not null,
	que nvarchar(100) not null,
	gioitinh bit not null,
	ngayvaolam date not null
)

create table hang
(
	mahang varchar(30) not null primary key,
	tenhang nvarchar(50) not null,
	nsx nvarchar(100) not null,
	hsd date not null,
	giaban money not null,
	soluongco int
)

create table qlthang
(
	date date not null,
	matv varchar(30),
	songaylam int not null,
	maluong varchar(30),
	constraint pk1 primary key(date,matv),
	constraint fk1 foreign key(matv) references thanhvien(matv),
	constraint fk2 foreign key(maluong) references luongcoban(maluong)
)

create table nhap
(
	date date not null,
	mahang varchar(30) not null,
	soluong int not null,
	gianhap money not null,
	constraint pk2 primary key(date,mahang),
	constraint fk3 foreign key(mahang) references hang(mahang)
)

create table hoadon
(
	mahoadon varchar(30) not null primary key,
	date date not null,
	matv varchar(30),
	constraint fk4 foreign key(matv) references thanhvien(matv)
)

create table chitiethoadon
(
	mahoadon varchar(30) not null,
	mahang varchar(30) not null,
	soluong int not null,
	constraint pk3 primary key(mahoadon,mahang),
	constraint fk5 foreign key(mahang) references hang(mahang),
	constraint fk6 foreign key(mahoadon) references hoadon(mahoadon)
)

---------------------------------------------------------------
--khoi tao cac gia tri ban dau trong moi bang
-- insert cho taikhoan gom 2 thanh vien va 1 quantri vien
insert into taikhoan values('Quan','04dvqkdk','quanly')
insert into taikhoan values('a1','abc123','nhanvien')
insert into taikhoan values('a2','abcd1234','nhanvien')
select * from taikhoan

--insert 2 thanh vien trong tiem
-- voi du lieu gioi tinh: 0 nu , 1 nam
insert into thanhvien values('a1',N'Bùi Ngọc Phương',18,N'Đông Anh - Hà Nội',0,'2015-1-1')
insert into thanhvien values('a2',N'Lê Hà Lan',21,N'Mê Linh - Hà Nội',0,'2015-8-10')
select * from thanhvien

-- insert cac mat hang thuoc
-- insert voi 5 du lieu mau
insert into hang values('b1',N'Xương khớp Nhất Nhất',N'CT Nhất Nhất','2023-12-08',100000,0)
insert into hang values('b2',N'SALONPAS',N'CT Hisamitsu','2022-11-18',20000,0)
insert into hang values('b3',N'new Choice',N'CT Nam Ha','2025-09-29',15000,0)
insert into hang values('b4',N'TETRACYCLIN',N'CT MEDIPHARCO','2025-12-12',5000,0)
insert into hang values('b5',N'Thuốc nhỏ mắt Ticoldex',N'CTY Danapha','2021-12-12',2000,0)
select* from hang

-- insert du lieu voi luongcoban
insert into Luongcoban values('d1',N'Giá ngày công',150000)
insert into Luongcoban values('d2',N'Giá nhà',3000000)
insert into Luongcoban values('d3',N'Giá điện nước',2000000)
insert into Luongcoban values('d4',N'Khác',0)
insert into Luongcoban values('d5',N'Hoa hồng',0)
select* from luongcoban

-- QL Thang
-- insert du lieu quan ly thang cho 2 nhana vien a1, va a2
-- trong 2 thang 3 va 4 nam 2021

insert into  qlthang values('2021-03-01','a1',25,'d1')
insert into  qlthang values('2021-04-01','a1',24,'d1')
insert into  qlthang values('2021-03-01','a2',21,'d1')
insert into  qlthang values('2021-04-01','a2',22,'d1')
select * from qlthang

-- insert du lieu cho nhap
-- vi du lieu nhap anh huong toi du lieu kho hang nen chung ta se phai tao mot trigger de thuc hien dieu nay
create trigger update_slhang
on nhap
for insert
as
	begin
		if(not exists(select * from hang inner join inserted on inserted.mahang= hang.mahang))
			begin
				raiserror('Loi khong co hang',16,1)
				rollback transaction
			end
		else
			begin
				declare @soluongnhap int
				select @soluongnhap= soluong from inserted
				update hang set soluongco= soluongco+@soluongnhap from hang inner join inserted on hang.mahang= inserted.mahang

			end
	end

create trigger update_slhang1 -- muc tieu de xoa mat hang
on nhap
for delete
as
	begin
		if(not exists(select * from hang inner join deleted on deleted.mahang= hang.mahang))
			begin
				raiserror('Loi khong co hang',16,1)
				rollback transaction
			end
		else
			begin
				declare @soluongnhap int
				select @soluongnhap= soluong from deleted
				update hang set soluongco= soluongco-@soluongnhap from hang inner join deleted on hang.mahang= deleted.mahang

			end
	end

select*from hang
select*from nhap
insert into nhap values('2021-01-01','b1',1000,70000)
insert into nhap values('2021-02-01','b2',1000,12000)
insert into nhap values('2021-01-02','b3',1000,10000)
insert into nhap values('2021-03-01','b4',1000,3000)
insert into nhap values('2021-03-03','b5',1000,1000)
select*from hang
select*from nhap

--bay h insert cho bang hoa don
--vi du trong mot ngay hai nhan vien ban duoc hai hoa don
insert into hoadon values('c20211','2021-03-03','a1')
insert into hoadon values('c20212','2021-04-03','a2')
select * from hoadon

--boi vi khi thuc hien ban hang se anh huong toi so luong trong kho hang len chung ta se viet mot trigger cho dieu nay
create trigger update_sluongco1
on chitiethoadon
for insert
as
	begin
		if(not exists(select * from hang inner join inserted on inserted.mahang= hang.mahang))
			begin
				raiserror('Loi khong co hang',16,1)
				rollback transaction
			end
		else
			begin
				declare @soluong int
				declare @soluongban int
				select @soluongban= soluong from inserted
				select @soluong = soluongco from hang inner join inserted on inserted.mahang=hang.mahang
				if(@soluongban>@soluong)
					begin
						raiserror('khong co du hang',16,1)
						rollback transaction
					end
				else
					begin
						update hang set soluongco= soluongco-@soluongban from hang inner join inserted on hang.mahang= inserted.mahang
					end
			end
		end

--tao mot trigger tinh tong tien


----------
select * from hang
select * from chitiethoadon
insert into chitiethoadon values('c20211','b1',2)
insert into chitiethoadon values('c20211','b2',1)
insert into chitiethoadon values('c20211','b3',1)
insert into chitiethoadon values('c20212','b3',2)
insert into chitiethoadon values('c20212','b4',3)
insert into chitiethoadon values('c20212','b5',4)
select * from hang
select * from chitiethoadon

-- nhu vay la da insert du lieu mau xong
------------------------------------------------------------------------

-- demo ve viec xu ly thoi gian

create function last_day(@date date)
returns date
as
	begin
		declare @cuoi date
		select @cuoi=DATEADD(MONTH,DATEDIFF(MONTH,0,@date)+ 1, 0) - 1
		return @cuoi
	end

select DBO.last_day('2021-5-26')

create function first_day(@date date)
returns date
as
	begin
		declare @kq date
		SELECT @kq= DATEFROMPARTS(Year(@date),MONTH(@date),1)

		return @kq
	end

select DBO.first_day(GETDATE())

select qlthang.matv,ten,songaylam from qlthang inner join thanhvien on thanhvien.matv= qlthang.matv
where date between (select DBO.first_day('2021-03-13')) and (select DBO.last_day('2021-03-13'))


create function show_luongthang(@date date)
returns @Table TABLE
(
	matv varchar(30),
	ten nvarchar(50),
	songaylam int,
	luong money
)
as
	begin
		declare @maluong money
		--declare @luong money
		select @maluong=tien from Luongcoban where maluong='d1'
		
		insert into @Table
			select qlthang.matv,ten,songaylam,(songaylam*@maluong)
			from qlthang inner join thanhvien on thanhvien.matv= qlthang.matv
			where date between (select DBO.first_day(@date)) and (select DBO.last_day(@date))

		return
	end

select * from show_luongthang('2021-03-14')

-- cach khach de lay last day
select EOMONTH('2020-1-1')
insert into  qlthang values((select EOMONTH('2020-02-02')),'a1',21,'d1')
select* from qlthang

select Hang.mahang,soluong,giaban from hang inner join chitiethoadon on hang.mahang=chitiethoadon.mahang where mahoadon='c20211'

create function show_mat_hang_mua(@mahoadon varchar(30))
returns @Table table
(
	mahang varchar(30),
	soluong int,
	giaban money,
	tongtien money
)
as 
	begin
		insert into @Table 
			select Hang.mahang,soluong,giaban,(soluong*giaban)
			from hang inner join chitiethoadon on hang.mahang=chitiethoadon.mahang
			where mahoadon = @mahoadon
		return
	end

	-- cai nay la datagridview hien thi sau khi an vao chon mat hang
create function show_mat_hang_mua1(@mahoadon varchar(30))
returns @Table table
(
	mahoadon varchar(30),
	mahang varchar(30),
	tenhang nvarchar(50),
	soluong int,
	giaban money,
	tongtien money
)
as 
	begin
		insert into @Table 
			select mahoadon,Hang.mahang,tenhang,soluong,giaban,(soluong*giaban)
			from hang inner join chitiethoadon on hang.mahang=chitiethoadon.mahang
			where mahoadon = @mahoadon
		return
	end

select * from dbo.show_mat_hang_mua1('c20211')

-- function nay voi muc dich la tinh tong tien mua hang
create function tongtien_muahang(@mahoadon varchar(30))
returns money
as
	begin
		declare @tong money
		select @tong= sum(tongtien) from dbo.show_mat_hang_mua1(@mahoadon)
		return @tong
	end

create function tong_ban1(@ngay date)
returns @Table table
(
	mahoadon varchar(30),
	mahang varchar(30),
	tenhang nvarchar(50),
	ngayban date,
	soluong int,
	giaban money,
	tongtien money
)
as 
	begin
		insert into @Table 
			select hoadon.mahoadon,Hang.mahang,tenhang,date,soluong,giaban,(soluong*giaban)
			from hang inner join chitiethoadon on hang.mahang=chitiethoadon.mahang inner join hoadon on hoadon.mahoadon= chitiethoadon.mahoadon
			where date between (select DBO.first_day(@ngay)) and (select DBO.last_day(@ngay))
		return
	end

select * from dbo.show_mat_hang_mua1('c20211')
select dbo.tongtien_muahang('c20211')


select * from dbo.tong_ban1('2021-04-12')


-- cai funtion nay giup chung ta co duoc tong thu toan bo thang
create function tong_ban(@date date)
returns money
as
	begin
		declare @tong money
		if(not exists(select * from dbo.tong_ban1(@date) where ngayban between (select DBO.first_day(@date)) and (select DBO.last_day(@date)) ))
			begin
				select @tong=0
			end
		else
			begin
				select @tong= sum(tongtien) from dbo.tong_ban1(@date)
			end
		return @tong
	end

-- voi truong hop co ngay
select * from dbo.tong_ban1('2021-04-12')
select dbo.tong_ban('2021-04-12')
-- voi truong hop k co ngay
select * from dbo.tong_ban1('2020-04-12')
select dbo.tong_ban('2020-04-12')

-- bay h viet chuc nang cho quan ly nhap hang
create function tong_nhap_hang1(@date date)
returns @Table Table
(
	ngaynhap date,
	mahang varchar(30),
	soluongnhap int,
	gianhap money,
	tongtien money
)
as
	begin
		insert into @Table
		select date,mahang,soluong,gianhap,(soluong*gianhap) from nhap where date between (select DBO.first_day(@date)) and (select DBO.last_day(@date))
		return
	end

create function tong_nhap_hang(@date date)
returns money
as
	begin
		declare @tong money
		if(not exists(select * from dbo.tong_nhap_hang1(@date) where ngaynhap between (select DBO.first_day(@date)) and (select DBO.last_day(@date)) ))
			begin
				select @tong=0
			end
		else
		begin
			select @tong= sum(tongtien) from dbo.tong_nhap_hang1(@date)
		end
		return @tong
	end

	-- kiem tra voi ngay hop le
select * from dbo.tong_nhap_hang1('2021-03-04')
select dbo.tong_nhap_hang('2021-03-04')
	-- kiem tra voi ngay khong hop le 
select * from dbo.tong_nhap_hang1('2020-03-04')
select dbo.tong_nhap_hang('2020-03-04')

-- bay h viet chuc nang cho quan ly thanh tien cho nhan vien
--b1 tinh tong tien nhan vien nay ban hang trong thang
create function tong_ban2(@ngay date)
returns @Table table
(
	mahoadon varchar(30),
	mahang varchar(30),
	tenhang nvarchar(50),
	ngayban date,
	matv varchar(30),
	soluong int,
	giaban money,
	tongtien money
)
as 
	begin
		insert into @Table 
			select hoadon.mahoadon,Hang.mahang,tenhang,date,matv,soluong,giaban,(soluong*giaban)
			from hang inner join chitiethoadon on hang.mahang=chitiethoadon.mahang inner join hoadon on hoadon.mahoadon= chitiethoadon.mahoadon
			where date between (select DBO.first_day(@ngay)) and (select DBO.last_day(@ngay))
		return
	end

select * from dbo.show_mat_hang_mua1('c20211')
select dbo.tongtien_muahang('c20211')

-- cai nay bo nhe
create function nhanvien_thang(@manv varchar(30),@ngay date)
returns money
as
	begin
		declare @tong money
		if(not exists(select * from dbo.tong_ban2(@ngay) where ngayban between (select DBO.first_day(@ngay)) and (select DBO.last_day(@ngay)) ))
			begin
				select @tong=0
			end
		else
			begin
				select @tong= sum(tongtien) from dbo.tong_ban2(@ngay) where matv=@manv
			end
		return @tong
	end

create function bangtinh_tong_tien_cong(@date date)
returns @Tbale table
(
	matv varchar(30),
	hoten nvarchar(50),
	songaylam int,
	luongthang money,
	hoahong money,
	tong money
)
as
	begin
		declare @maluong money
		declare @mathuong money
		select @maluong=tien from Luongcoban where maluong='d1'
		select @mathuong= tien from Luongcoban where maluong='d5'
		insert @Tbale
			select qlthang.matv,ten,songaylam,(songaylam*@maluong),(@mathuong*(select dbo.nhanvien_thang(qlthang.matv,@date))),((songaylam*@maluong)+(@mathuong*(select dbo.nhanvien_thang(qlthang.matv,@date))))
			from qlthang inner join thanhvien on thanhvien.matv= qlthang.matv
			where date between (select DBO.first_day(@date)) and (select DBO.last_day(@date))
		return 
	end

select dbo.nhanvien_thang('a1','2021-04-12')
select * from dbo.bangtinh_tong_tien_cong('2021-04-12')
---

-- lam lai 2 cai funtion tren
create function nhanvien_thang1(@manv varchar(30),@ngay date)
returns money
as
	begin
		declare @tong money
		if(not exists(select*from dbo.tong_ban2(@ngay) where matv=@manv and ngayban between (select DBO.first_day(@ngay)) and (select DBO.last_day(@ngay))  ))
			begin
				select @tong = 0
				
			end
		else
			begin
				select @tong= sum(tongtien) from dbo.tong_ban2(@ngay) where matv=@manv
				
			end
		return @tong
	end

create function bangtinh_tong_tien_cong1(@date date)
returns @Tbale table
(
	matv varchar(30),
	hoten nvarchar(50),
	songaylam int,
	luongthang money,
	hoahong money,
	tong money
)
as
	begin
		declare @maluong money
		declare @mathuong money
		select @maluong=tien from Luongcoban where maluong='d1'
		select @mathuong= tien/100 from Luongcoban where maluong='d5'
		insert @Tbale
			select qlthang.matv,ten,songaylam,(songaylam*@maluong),(@mathuong*(select dbo.nhanvien_thang1(qlthang.matv,@date))),((songaylam*@maluong)+(@mathuong*(select dbo.nhanvien_thang1(qlthang.matv,@date))))
			from qlthang inner join thanhvien on thanhvien.matv= qlthang.matv
			where date between (select DBO.first_day(@date)) and (select DBO.last_day(@date))
		return 
	end

-- th1 hop le
select dbo.nhanvien_thang1('a1','2021-03-12')
select * from dbo.bangtinh_tong_tien_cong1('2021-03-12')
-- th2 khong hop le
select dbo.nhanvien_thang1('a1','2020-03-12')
select * from dbo.bangtinh_tong_tien_cong1('2020-03-12')

-- cai nay se tinh tong tien cong tat ca
create function tong_tien_cong(@date date)
returns money
as
	begin
		declare @tong money
	
		
		
			select @tong= sum(tong) from bangtinh_tong_tien_cong1(@date) 
		
		return @tong
	end

	-- hop len ngay
select dbo.nhanvien_thang1('a2','2021-03-12')
select * from dbo.bangtinh_tong_tien_cong1('2021-03-12')
select dbo.tong_tien_cong('2021-03-12')
-- khong hop le ngay
select dbo.nhanvien_thang1('a2','2020-03-12')
select * from dbo.bangtinh_tong_tien_cong1('2020-03-12')
select dbo.tong_tien_cong('2020-03-12')

-- function nay se thong ke tat ca
create function thongke(@date date)
returns money
as
	begin
		declare @tong money
		declare @ban money
		declare @nhap money
		declare @nhancong money
		declare @diennuoc money
		declare @nha money
		declare @khac money
		select @nha = tien from Luongcoban where maluong='d2'
		select @diennuoc= tien from Luongcoban where maluong='d3'
		select @khac= tien from Luongcoban where maluong='d4'
		select @nhancong = (select dbo.tong_tien_cong(@date))
		select @nhap= (select dbo.tong_nhap_hang(@date))
		select @ban= (select dbo.tong_ban(@date))

		select @tong= @ban-(@nhancong+@nha+@diennuoc+@khac+@nhap)
		return @tong
	end

create function tong_chi(@date date)
returns money
as
	begin
		declare @tong money
		
		declare @nhap money
		declare @nhancong money
		declare @diennuoc money
		declare @nha money
		declare @khac money
		select @nha = tien from Luongcoban where maluong='d2'
		select @diennuoc= tien from Luongcoban where maluong='d3'
		select @khac= tien from Luongcoban where maluong='d4'
		select @nhancong = (select dbo.tong_tien_cong(@date))
		select @nhap= (select dbo.tong_nhap_hang(@date))
		

		select @tong= @nhancong+@nha+@diennuoc+@khac+@nhap
		return @tong
	end

select dbo.tong_ban('2021-01-11')

-- trong truong hop nhan vien khong ban duoc hang nao thi cx k co luong vay nen cx phai kiem tra ca dk nay nx
-- => kiem tra tinh tongnhanvienban
select dbo.tong_tien_cong('2021-02-11')-- ca cai tinh tong tien cong cung can kiem tra tinh ton tai
select dbo.tong_nhap_hang('2021-04-11')-- cai tong nhap thang can kiem tra xem ngay co ton tai khong
select dbo.tong_chi('2021-04-11')-- tong chi bi phu thuoc vao 2 cai tong nhap hang va tong tien cong nen k can phai thay doi
select dbo.thongke('2021-04-11')

-- th khong hop le
select dbo.tong_ban('2020-01-11')
select dbo.tong_tien_cong('2020-01-11')
select dbo.tong_nhap_hang('2020-01-11')
select dbo.tong_chi('2020-01-11')
select dbo.thongke('2020-01-11')



