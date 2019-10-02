require "gc_stats/version"

module GcStats
  class Error < StandardError; end

  HUMAN_STATS = {
    count: 'The number of GC runs, major and minor combined',
    minor_gc_count: 'Minor Garbage collections ran since the start of this ruby process',
    major_gc_count: 'Major Garbage collections ran since the start of this ruby process',

    total_allocated_object: 'The total number of objects Ruby has allocated in the lifetime of the current process.',
    total_freed_object: 'Freed objects in the lifetime of the current process.',

    heap_length: 'Heap pages the current Ruby process has allocated',
    heap_used: 'Heap pages that are currently in use',
    heap_eden_pages: 'Heap pages that contain (at least one) live objects',
    heap_tomb_pages: 'Pages that do not contain live objects',
    heap_live_slots: 'Objects that survived all the GC runs in the past and are still alive',
    heap_free_slots: 'Allocated but unused/free slots on the Ruby heap',
    heap_available_slots: 'Total number of slots in heap pages',
    heap_marked_slots: 'Count of old objects (objects that have survived more than 3 GC cycles)',
    heap_final_slots: 'Object slots which have finalizers attached to them',
    heap_sorted_length: 'Actual size of the heap in memory',
    heap_allocated_pages: 'Currently allocated heap pages',
    heap_allocatable_pages: 'Heap-page-sized chunks of memory that Ruby currently owns (i.e., has already malloced',

    total_allocated_pages: 'Total allocated pages',
    total_freed_pages: 'Total freed pages',
    total_freed_objects: 'Total freed objects',

    malloc_increase_bytes: 'Allocated space for objects outside of the “heap”',

    remembered_wb_unprotected_objects: 'Objects which are not protected by the write-barrier and are part of the remembered set',

    old_objects: 'Count of object slots marked as old'
  }.freeze

  def initialize(statistics = GC.stat)
    @statistics = statistics
  end

  def humanized_info
    humanized_stats = {}
    @statistics.each { |key, value| humanized_stats["(#{key}) - #{HUMAN_STATS[key]}"] = value }

    humanized_stats
  end

  def unoccupied_free_slots_info
    "Unoccupied free slots from eden pages (pages which currently contain at least one live object) "\
    "is #{unoccupied_free_slots_percentage}% \n"
  end

  def internal_fragmentation_info
    "Internal fragmentation at the level of ObjectSpace pages is #{internal_fragmentation}%. "\
    "A high percentage here would indicate a lot of heap-page-sized “holes” in the ObjectSpace list."
  end

  private

  def unoccupied_free_slots_percentage
    (100 - (
      (@statistics[:heap_live_slots] / (@statistics[:heap_eden_pages] * GC::INTERNAL_CONSTANTS[:HEAP_PAGE_OBJ_LIMIT]).to_f) * 100)
    ).round(2)
  end

  def internal_fragmentation
    (100 - (
      (@statistics[:heap_eden_pages] / @statistics[:heap_sorted_length].to_f) * 100)
    ).round(2)
  end
end
