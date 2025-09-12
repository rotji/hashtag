import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.8.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "User Roles: Ensures a user has the default 'participant' role",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;

        // Call the get-role read-only function for a new user
        const role = chain.callReadOnlyFn('user-roles', 'get-role', [types.principal(wallet1.address)], deployer.address);

        // Assert that the default role is "participant"
        role.result.expectOk().expectAscii("participant");
    },
});

Clarinet.test({
    name: "User Roles: Allows the contract owner (admin) to set a role",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;

        // The admin (deployer) sets the role for wallet_1 to "brand"
        const block = chain.mineBlock([
            Tx.contractCall('user-roles', 'set-role', [types.principal(wallet1.address), types.ascii("brand")], deployer.address),
        ]);

        // The transaction should be successful
        block.receipts[0].result.expectOk().expectBool(true);

        // Verify the new role was set
        const updatedRole = chain.callReadOnlyFn('user-roles', 'get-role', [types.principal(wallet1.address)], deployer.address);
        updatedRole.result.expectOk().expectAscii("brand");
    },
});

Clarinet.test({
    name: "User Roles: Prevents a non-admin from setting a role",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const wallet1 = accounts.get('wallet_1')!;
        const wallet2 = accounts.get('wallet_2')!;

        // A non-admin (wallet_1) attempts to set a role for wallet_2
        const block = chain.mineBlock([
            Tx.contractCall('user-roles', 'set-role', [types.principal(wallet2.address), types.ascii("admin")], wallet1.address),
        ]);

        // The transaction should fail with the unauthorized error (err u201)
        block.receipts[0].result.expectErr().expectUint(201);
    },
});

Clarinet.test({
    name: "User Roles: Prevents setting an invalid role type",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const wallet1 = accounts.get('wallet_1')!;

        // The admin attempts to set an invalid role for wallet_1
        const block = chain.mineBlock([
            Tx.contractCall('user-roles', 'set-role', [types.principal(wallet1.address), types.ascii("super-user")], deployer.address),
        ]);

        // The transaction should fail with the invalid role error (err u202)
        block.receipts[0].result.expectErr().expectUint(202);
    },
});
