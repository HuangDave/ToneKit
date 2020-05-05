#	mkdir tools
#	cd tools
#	git clone https://github.com/yonaskolb/Mint.git
#	cd Mint
#	make
#	swift run mint install MakeAWishFoundation/SwiftyMocky

make mocks:
	swiftymocky doctor
	swiftymocky generate
