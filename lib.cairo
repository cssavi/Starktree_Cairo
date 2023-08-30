use starknet::ContractAddress;

#[starknet::interface]
trait OwnableTrait<T> {
    fn add_link(ref self: T, owner: ContractAddress, link: felt252);
    fn get_link(self: @T, owner: ContractAddress) -> felt252;
}

#[starknet::contract]
mod Ownable {
    use super::ContractAddress;
    use starknet::get_caller_address;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        TransferredLink: TransferredLink,
    }

    #[derive(Drop, starknet::Event)]
    struct TransferredLink {
        #[key]
        prev_link: felt252,
        #[key]
        link: felt252,
    }

    #[storage]
    struct Storage {
        map: LegacyMap::<ContractAddress, felt252>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, init_owner: ContractAddress) {
        self.map;
    }
    
    #[external(v0)]
    impl OwnableImpl of super::OwnableTrait<ContractState> {   
        fn add_link(ref self: ContractState, owner: ContractAddress, link: felt252) {
            let prev_link = self.map.read(owner);
            self.map.write(owner, link);
            self.emit(Event::TransferredLink(TransferredLink {
                prev_link: prev_link,
                link: link,
            }));
        }

        fn get_link(self: @ContractState, owner: ContractAddress) -> felt252 {
            self.map.read(owner)
        }
    }
}