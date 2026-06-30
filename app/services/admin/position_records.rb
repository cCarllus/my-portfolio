module Admin
  class PositionRecords
    class InvalidOrder < StandardError; end

    class << self
      def append(record, scope:)
        maximum = scope.maximum(:position)
        record.position = maximum ? maximum + 1 : 0
      end

      def reorder(scope:, ids:)
        ordered_ids = Array(ids).map(&:to_i)
        records = scope.where(id: ordered_ids).index_by(&:id)
        complete_order = records.size == ordered_ids.uniq.size && scope.count == ordered_ids.size
        raise InvalidOrder unless complete_order

        ApplicationRecord.transaction do
          ordered_ids.each_with_index do |id, position|
            records.fetch(id).update!(position:)
          end
        end
      end
    end
  end
end
