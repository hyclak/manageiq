require_migration

describe AddUpdateRepoNameToMiqDatabase do
  let(:db_stub)      { migration_stub(:MiqDatabase) }
  let(:reserve_stub) { Spec::Support::MigrationStubs.reserved_stub }

  migration_context :up do
    it "Migrates :update_repo_name from Reserves table to new column on MiqDatabase" do
      db = db_stub.create!
      reserve_stub.create!(
        :resource_type => "MiqDatabase",
        :resource_id   => db.id,
        :reserved      => {
          :update_repo_name => "abc"
        }
      )

      migrate

      # Expect counts
      expect(reserve_stub.count).to be(0)
      expect(db_stub.count).to      be(1)

      # Expect data
      expect(db.reload.update_repo_name).to eq("abc")
    end
  end

  migration_context :down do
    it "Migrates :update_repo_name from column on MiqDatabase to Reserves table" do
      db = db_stub.create!(:update_repo_name => "abc")

      migrate

      # Expect counts
      expect(reserve_stub.count).to be(1)
      expect(db_stub.count).to      be(1)

      # Expect data
      expect(reserve_stub.first.resource_id).to    eq(db.id)
      expect(reserve_stub.first.resource_type).to  eq("MiqDatabase")
      expect(reserve_stub.first.reserved).to       eq(:update_repo_name => "abc")
    end
  end
end
